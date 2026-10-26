import 'dart:async';
import 'dart:developer';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/Data/Services/IncommingCallKit/callkit_service.dart:.dart';

import 'package:fgtracker/app/modules/Track/Controller/GroupTrackController.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/call_audio_route_controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../gen/assets.gen.dart';

import 'package:fgtracker/app/Model/callDetailRes.dart';

import '../../../Data/Services/IncommingCallKit/call_session.dart'
    show CallSessionState;
import '../../../Data/Services/Socket/Socket_SignallingService.dart';
import '../Widget/audio_route_sheet.dart';

class CallingController extends GetxController with WidgetsBindingObserver {
  static const String _camTag = 'a=x-cam-on:';

  final socket = SignallingService.instance.socket;

  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();

  RTCPeerConnection? peer;
  MediaStream? localStream;
  MediaStream? _remoteMediaStream;
  MediaStreamTrack? _remoteVideoTrack;
  RTCRtpSender? _localVideoSender;
  bool _remoteCamStateKnown = false;
  RTCRtpTransceiver? _remoteVideoTransceiver;
  MediaStream? _fallbackRemoteStream;
  bool _videoSlotReady = false;
  Timer? _firstFrameTimer;
  Timer? _qualityTimer;
  final RxBool isRemoteVideoLoading = false.obs;

  List<RTCIceCandidate> iceCandidates = [];
  RxString callStatus = "Calling".obs;
  bool isAudioOn = true;
  bool isVideoOn = false;
  bool isRemoteVideoOn = false;
  bool isFrontCamera = true;
  bool _isSwitchingCamera = false;
  dynamic callId;
  late String callerId;
  late String remoteUserId;
  late bool is_video;
  dynamic offer;
  bool isSpeakerOn = false;
  bool fromCallKit = false;
  bool _isCleaningUp = false;
  bool _hasExitedScreen = false;
  bool _remoteEndSent = false;
  bool _callKitConnectedSent = false;
  bool _audioRouteRestored = false;
  bool _renegotiating = false;
  bool _pendingRenegotiation = false;
  bool _localOfferPending = false;

  Timer? _peerDisconnectTimer;

  bool _everConnected = false;
  final args = Get.arguments;
  Timer? callTimer;
  int callDurationSeconds = 0;
  final RxInt callDurationRx = 0.obs;
  Offset? pipPosition;
  final Rxn<CallDetail> apiCallDetail = Rxn<CallDetail>();

  Timer? missedCallTimer;
  var missCallDurationSeconds = 40.obs;

  final RxBool isVideoCall = false.obs;
  final RxBool isUpgradingToVideo = false.obs;
  final RxBool isRemoteUpgrading = false.obs;
  Timer? _remoteUpgradeTimer;

  bool isLocalVideoMain = false;

  final RxBool areControlsVisible = true.obs;
  Timer? _controlsTimer;

  late final CallAudioRouteController audioRouteController;
  late final String _audioRouteTag;

  final List<dynamic> _pendingRemoteCandidates = [];
  bool _remoteDescriptionSet = false;

  Map<String, dynamic> _videoCaptureConstraints() {
    final String facing = isFrontCamera ? 'user' : 'environment';

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return <String, dynamic>{
        'facingMode': facing,
        'width': 1280,
        'height': 720,
        'frameRate': 30,
      };
    }

    return <String, dynamic>{
      'facingMode': facing,
      'width': <String, dynamic>{'ideal': 1280, 'max': 1280},
      'height': <String, dynamic>{'ideal': 720, 'max': 720},
      'frameRate': <String, dynamic>{'min': 24, 'ideal': 30, 'max': 30},
    };
  }

  String _preferH264InSdp(String sdp) {
    if (sdp.isEmpty || !sdp.contains('m=video')) return sdp;

    final String lineSep = sdp.contains('\r\n') ? '\r\n' : '\n';
    final List<String> lines = sdp.split(lineSep);

    int i = 0;
    while (i < lines.length) {
      if (!lines[i].startsWith('m=video ')) {
        i++;
        continue;
      }

      final int mLineIdx = i;
      int sectionEnd = i + 1;
      while (sectionEnd < lines.length && !lines[sectionEnd].startsWith('m=')) {
        sectionEnd++;
      }

      final List<String> h264BaselinePts = <String>[];
      final List<String> h264OtherPts = <String>[];
      final Map<String, String> rtxByApt = <String, String>{};
      final Map<String, String> fmtpByPt = <String, String>{};

      for (int k = mLineIdx + 1; k < sectionEnd; k++) {
        final String line = lines[k];
        if (line.startsWith('a=fmtp:')) {
          final int space = line.indexOf(' ');
          if (space > 7) {
            final String pt = line.substring(7, space).trim();
            final String params = line.substring(space + 1).trim();
            fmtpByPt[pt] = params.toLowerCase();
            final RegExpMatch? aptMatch = RegExp(r'(?:^|;\s*)apt=(\d+)')
                .firstMatch(params);
            if (aptMatch != null) {
              rtxByApt[aptMatch.group(1)!] = pt;
            }
          }
        }
      }

      for (int k = mLineIdx + 1; k < sectionEnd; k++) {
        final RegExpMatch? m = RegExp(
          r'^a=rtpmap:(\d+)\s+H264/90000',
          caseSensitive: false,
        ).firstMatch(lines[k]);
        if (m == null) continue;
        final String pt = m.group(1)!;
        final String fmtp = fmtpByPt[pt] ?? '';
        if (fmtp.contains('42e0') || fmtp.contains('4200')) {
          h264BaselinePts.add(pt);
        } else {
          h264OtherPts.add(pt);
        }
      }

      final List<String> orderedH264 = <String>[
        ...h264BaselinePts,
        ...h264OtherPts,
      ];

      if (orderedH264.isNotEmpty) {
        final List<String> parts = lines[mLineIdx].trim().split(RegExp(r'\s+'));
        if (parts.length > 4) {
          final List<String> header = parts.sublist(0, 3);
          final List<String> origPayloads = parts.sublist(3);
          final Set<String> origSet = origPayloads.toSet();
          final List<String> reordered = <String>[];

          for (final String pt in orderedH264) {
            if (origSet.contains(pt) && !reordered.contains(pt)) {
              reordered.add(pt);
            }
            final String? rtxPt = rtxByApt[pt];
            if (rtxPt != null &&
                origSet.contains(rtxPt) &&
                !reordered.contains(rtxPt)) {
              reordered.add(rtxPt);
            }
          }

          for (final String pt in origPayloads) {
            if (!reordered.contains(pt)) {
              reordered.add(pt);
            }
          }

          lines[mLineIdx] = <String>[...header, ...reordered].join(' ');
        }
      }

      i = sectionEnd;
    }

    return lines.join(lineSep);
  }

  String _stripCamTag(String sdp) {
    if (sdp.isEmpty || !sdp.contains(_camTag)) return sdp;
    final String sep = sdp.contains('\r\n') ? '\r\n' : '\n';
    return sdp
        .split(sep)
        .where((String line) => !line.trim().startsWith(_camTag))
        .join(sep);
  }

  String _withCamTag(String sdp, bool cameraOn) {
    if (sdp.isEmpty) return sdp;
    final String sep = sdp.contains('\r\n') ? '\r\n' : '\n';
    final String tag = '$_camTag${cameraOn ? 1 : 0}';
    final List<String> out = <String>[];
    for (final String line in _stripCamTag(sdp).split(sep)) {
      out.add(line);
      if (line.startsWith('m=video ')) out.add(tag);
    }
    return out.join(sep);
  }

  bool? _camStateFromSdp(String? sdp) {
    if (sdp == null || sdp.isEmpty || !sdp.contains(_camTag)) return null;
    return sdp.contains('${_camTag}1');
  }

  String _sdpInfo(String? sdp) {
    if (sdp == null || sdp.isEmpty) return 'sdp=empty';

    final String sep = sdp.contains('\r\n') ? '\r\n' : '\n';
    final List<String> lines = sdp.split(sep);
    final List<String> mlines = <String>[];
    int msid = 0;
    int ssrc = 0;
    int ssrcGroup = 0;
    int rtpmap = 0;
    int fmtpH264 = 0;
    String current = '?';

    for (final String raw in lines) {
      final String line = raw.trim();
      if (line.startsWith('m=')) {
        final List<String> p = line.split(RegExp(r'\s+'));
        current = p.isNotEmpty ? p[0].substring(2) : '?';
        mlines.add('$current:?');
      } else if (line.startsWith('a=sendrecv') ||
          line.startsWith('a=recvonly') ||
          line.startsWith('a=sendonly') ||
          line.startsWith('a=inactive')) {
        if (mlines.isNotEmpty) {
          mlines[mlines.length - 1] = '$current:${line.substring(2)}';
        }
      } else if (line.startsWith('a=msid:')) {
        msid++;
      } else if (line.startsWith('a=ssrc:')) {
        ssrc++;
      } else if (line.startsWith('a=ssrc-group:')) {
        ssrcGroup++;
      } else if (line.startsWith('a=rtpmap:')) {
        rtpmap++;
        if (line.toUpperCase().contains('H264')) fmtpH264++;
      }
    }

    return 'mlines=${mlines.join(',')} msid=$msid ssrc=$ssrc '
        'ssrcGroup=$ssrcGroup rtpmap=$rtpmap h264=$fmtpH264';
  }

  RTCSessionDescription _prepareRemote(String? sdp, String? type) {
    final String raw = _stripCamTag(sdp ?? '');
    return RTCSessionDescription(_preferH264InSdp(raw), type);
  }

  Future<void> _tuneLocalVideoSender({double? scaleDown}) async {
    final RTCRtpSender? sender = _localVideoSender;
    if (sender == null) return;
    try {
      final RTCRtpParameters params = sender.parameters;
      params.degradationPreference =
          RTCDegradationPreference.MAINTAIN_FRAMERATE;
      final List<RTCRtpEncoding>? encodings = params.encodings;
      if (encodings != null && encodings.isNotEmpty) {
        for (final RTCRtpEncoding enc in encodings) {
          enc.active = true;
          enc.maxBitrate = 1800000;
          enc.maxFramerate = 30;
          if (scaleDown != null && scaleDown > 0) {
            enc.scaleResolutionDownBy = scaleDown;
          }
        }
      }
      await sender.setParameters(params);
      // log(
      //   "[CAM] tune sender scaleDown=${scaleDown ?? 'keep'} "
      //       "enc=${encodings?.length ?? 0}",
      // );
    } catch (e) {
      log("[Call] Video sender tuning skipped: $e");
    }
  }

  Future<void> _applyLocalVideoSending(MediaStreamTrack? track) async {
    final RTCRtpSender? sender = _localVideoSender;
    if (sender == null) return;
    try {
      await sender.replaceTrack(track);
    } catch (e) {
      log("[Call] replaceTrack error: $e");
    }
  }

  Future<MediaStream?> _remoteStreamForVideo() async {
    final MediaStream? stored = _remoteMediaStream;
    if (stored != null && stored.getVideoTracks().isNotEmpty) return stored;

    final MediaStreamTrack? track = _remoteVideoTrack;
    if (track == null) return null;

    final MediaStream? existing = _fallbackRemoteStream;
    if (existing != null && existing.getVideoTracks().isNotEmpty) {
      return existing;
    }

    try {
      final MediaStream stream = await createLocalMediaStream('cam_fallback');
      await stream.addTrack(track);
      _fallbackRemoteStream = stream;
      // log("[CAM] fallback stream built for remote video id=${track.id}");
      return stream;
    } catch (e) {
      log("[CAM] fallback stream failed: $e");
      return null;
    }
  }

  Future<void> _ensureRemoteVideoBound() async {
    if (isClosed || peer == null) return;
    if (remoteRenderer.srcObject != null) {
      log("[CAM] ensureBound: already bound");
      return;
    }
    // log(
    //   "[CAM] ensureBound: binding now track=${_remoteVideoTrack?.id} "
    //       "storedVideo=${_remoteMediaStream?.getVideoTracks().length ?? -1}",
    // );

    final MediaStream? stream = await _remoteStreamForVideo();
    if (stream == null) return;

    final String? trackId =
        _remoteVideoTrack?.id ?? stream.getVideoTracks().last.id;

    await remoteRenderer.setSrcObject(stream: stream, trackId: trackId);
  }

  Future<void> _syncVideoState() async {
    if (isVideoOn || isRemoteVideoOn) {
      isVideoCall.value = true;
      is_video = true;
    }

    if (!isVideoCall.value) {
      isLocalVideoMain = false;
      update();
      return;
    }

    if (isVideoOn && !isRemoteVideoOn) {
      isLocalVideoMain = true;
    } else if (!isVideoOn && isRemoteVideoOn) {
      isLocalVideoMain = false;
    }

    await _ensureRemoteVideoBound();

    update();
  }

  Future<bool> _ensureLocalVideoTrackAttached(
      RTCPeerConnection pc, {
        bool muted = false,
      }) async {
    bool needsRenegotiation = false;
    if (localStream == null) return needsRenegotiation;

    final List<MediaStreamTrack> existingTracks = localStream!.getVideoTracks();
    MediaStreamTrack? videoTrack = existingTracks.isNotEmpty
        ? existingTracks.first
        : null;

    if (videoTrack == null) {
      final MediaStream videoStream = await navigator.mediaDevices.getUserMedia(
        {'audio': false, 'video': _videoCaptureConstraints()},
      );
      videoTrack = videoStream.getVideoTracks().firstOrNull;
      if (videoTrack == null) {
        throw Exception("No video track available");
      }
      await localStream!.addTrack(videoTrack);
    }

    for (final MediaStreamTrack t in localStream!.getVideoTracks()) {
      t.enabled = !muted;
    }

    if (_localVideoSender == null) {
      final RTCRtpTransceiver? slot = _remoteVideoTransceiver;
      if (_videoSlotReady && slot != null) {
        _localVideoSender = slot.sender;
        await _applyLocalVideoSending(videoTrack);
        // log("[CAM] attach: replaced track on negotiated slot");
      } else {
        _localVideoSender = await pc.addTrack(videoTrack, localStream!);
        needsRenegotiation = true;
        log("[CAM] attach: addTrack needsRenegotiation=true");
      }
    } else {
      await _applyLocalVideoSending(videoTrack);
    }

    if (!muted) {
      await localRenderer.setSrcObject(
        stream: localStream,
        trackId: videoTrack.id,
      );
    }

    _logCaptureSettings(muted ? "answer-muted" : "upgrade");
    await _tuneLocalVideoSender();
    return needsRenegotiation;
  }

  Future<void> _renegotiateVideo() async {
    final RTCPeerConnection? pc = peer;
    if (pc == null || isClosed) return;

    if (_renegotiating) {
      _pendingRenegotiation = true;
      return;
    }

    _renegotiating = true;
    try {
      final RTCSessionDescription rawOffer = await pc.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      final RTCSessionDescription desc = RTCSessionDescription(
        _withCamTag(_preferH264InSdp(rawOffer.sdp ?? ''), isVideoOn),
        rawOffer.type,
      );
      await pc.setLocalDescription(desc);
      _localOfferPending = true;
      // log(
      //   "[SDP] local offer ${_sdpInfo(desc.sdp)} "
      //       "videoOn=$isVideoOn sender=${_localVideoSender != null}",
      // );

      final String myUserId = Global.storageServices
          .get(PrefConst.userId)
          .toString();
      final String targetUser = (myUserId == callerId.toString())
          ? remoteUserId
          : callerId;

      socket?.emit("upgradeToVideo", {
        "callId": callId,
        "remoteUserId": targetUser,
        "sdpOffer": desc.toMap(),
        "callerId": myUserId,
      });
    } catch (e) {
      log("[Call] renegotiate error: $e");
    } finally {
      _renegotiating = false;
      if (_pendingRenegotiation) {
        _pendingRenegotiation = false;
        unawaited(_renegotiateVideo());
      }
    }
  }

  Future<void> _applyRemoteSdp(RTCPeerConnection pc, dynamic sdp) async {
    final RTCSessionDescription desc = _prepareRemote(
      sdp?["sdp"]?.toString(),
      sdp?["type"]?.toString(),
    );
    // log(
    //   "[SDP] setRemote type=${desc.type} ${_sdpInfo(desc.sdp)} "
    //       "samePeer=${identical(peer, pc)}",
    // );
    try {
      await pc.setRemoteDescription(desc);
    } catch (e) {
      log("[Call] setRemoteDescription retry after rollback: $e");
      try {
        await pc.setLocalDescription(RTCSessionDescription('', 'rollback'));
      } catch (_) {}
      await pc.setRemoteDescription(desc);
    }
    await _markRemoteDescriptionSet();
  }

  void _emitEndCallRealtime({Map<String, dynamic>? customPayload}) {
    if (_remoteEndSent) return;
    _remoteEndSent = true;

    final String myUserId = Global.storageServices
        .get(PrefConst.userId)
        .toString();
    final String targetUser = myUserId == callerId.toString()
        ? remoteUserId
        : callerId;

    final Map<String, dynamic> payload =
        customPayload ??
            <String, dynamic>{
              "callId": callId,
              "to": targetUser,
              "remoteUserId": targetUser,
              "callerId": callerId,
              "receiverId": remoteUserId,
              "sessionId": _sessionId,
            };

    final dynamic s = socket;
    if (s == null) return;

    try {
      if (s.connected == true) {
        s.emit("endCall", payload);
      } else {
        s.emit("endCall", payload);
        s.once("connect", (_) {
          try {
            s.emit("endCall", payload);
          } catch (_) {}
        });
        s.connect();
      }
    } catch (e) {
      log("[Call] _emitEndCallRealtime error: $e");
    }
  }

  void _exitCallScreen() {
    if (_hasExitedScreen) return;
    _hasExitedScreen = true;

    final NavigatorState? nav = Get.key.currentState;
    if (nav != null) {
      nav.popUntil((route) => route is! PopupRoute);
      if (nav.canPop()) {
        nav.pop();

        String? topRouteName;
        nav.popUntil((route) {
          topRouteName = route.settings.name;
          return true;
        });

        final String normalized = (topRouteName ?? '').trim().toLowerCase();
        final bool landedOnSplash =
            normalized.isEmpty ||
                normalized == '/' ||
                normalized.contains('splash') ||
                (fromCallKit &&
                    !nav.canPop() &&
                    topRouteName != Routes.Home_Screen);

        if (!landedOnSplash) {
          return;
        }
      }
    }

    Get.offAllNamed(Routes.Home_Screen);
  }

  void toggleVideoViews() {
    if (!isVideoCall.value) return;
    if (!isVideoOn || !isRemoteVideoOn) {
      showControlsTemporarily();
      update();
      return;
    }
    isLocalVideoMain = !isLocalVideoMain;
    showControlsTemporarily();
    update();
  }

  void showControlsTemporarily() {
    areControlsVisible.value = true;
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 5), () {
      if (!isClosed) {
        areControlsVisible.value = false;
      }
    });
    update();
  }

  void toggleControls() {
    areControlsVisible.value = !areControlsVisible.value;
    _controlsTimer?.cancel();
    update();
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    callerId = args["callerId"]?.toString() ?? "";
    remoteUserId = args["remoteUserId"]?.toString() ?? "";
    offer = args["offer"];
    is_video = args["is_video"] == true;
    fromCallKit = args["fromCallKit"] == true;

    if (args["callId"] != null) {
      callId = args["callId"];
    }

    if (callId == null && args["sessionId"] != null) {
      callId = args["sessionId"];
    }

    if (args["sessionId"] != null && args["sessionId"].toString().isNotEmpty) {
      CallSessionState.sessionId = args["sessionId"].toString();
    }

    isVideoOn = is_video;
    isRemoteVideoOn = is_video;
    isVideoCall.value = is_video;

    // log(
    //   "[CAM] init callType=${args["callType"]} is_video=$is_video "
    //       "callerId=$callerId remoteUserId=$remoteUserId callId=$callId "
    //       "hasOffer=${offer != null} fromCallKit=$fromCallKit",
    // );

    _audioRouteTag =
    "call_audio_${callId ?? DateTime.now().microsecondsSinceEpoch}";

    audioRouteController = Get.put(
      CallAudioRouteController(),
      tag: _audioRouteTag,
    );

    _listenForCallEvents();

    if (args["callType"] == "outGoing") {
      playSound();
    }

    WakelockPlus.enable();

    try {
      GroupTrackingController.instance.initializeLocation();
    } catch (e) {
      log("[Call] Location initialization error: $e");
    }

    unawaited(_initializeCall());
  }

  void _onRendererFrameEvent([int? width, int? height]) {
    if (!isClosed) update();
  }

  void _logCaptureSettings(String tag) {
    final List<MediaStreamTrack> vids =
        localStream?.getVideoTracks() ?? <MediaStreamTrack>[];
    if (vids.isEmpty) {
      log("[CAM] capture($tag): no video track");
      return;
    }
    final Map<String, dynamic> st = vids.first.getSettings();
    log(
      "[CAM] capture($tag): ${st['width']}x${st['height']} "
          "fps=${st['frameRate']}",
    );
  }

  Future<void> _rebindRemoteForFirstFrames({bool generic = false}) async {
    if (isClosed || peer == null) return;

    final MediaStream? stream = await _remoteStreamForVideo();
    if (stream == null) {
      log("[CAM] rebind skipped: no remote video stream available");
      return;
    }

    final String? trackId =
        _remoteVideoTrack?.id ?? stream.getVideoTracks().last.id;
    try {
      remoteRenderer.srcObject = null;
      if (generic) {
        await remoteRenderer.setSrcObject(stream: stream);
        // log("[CAM] rebind generic stream=${stream.id}");
      } else {
        await remoteRenderer.setSrcObject(stream: stream, trackId: trackId);
        log("[CAM] rebind on remote camera on id=$trackId");
      }
    } catch (e) {
      log("[CAM] rebind failed: $e");
    }
  }

  Future<int> _logStats(String tag) async {
    final RTCPeerConnection? pc = peer;
    if (pc == null || isClosed) return -1;

    int decoded = -1;
    // log("[STAT] $tag begin");
    try {
      final List<StatsReport> reports = await pc.getStats();
      final Map<String, int> types = <String, int>{};

      for (final StatsReport r in reports) {
        final Map<dynamic, dynamic> v = r.values;
        final String type = r.type;
        types[type] = (types[type] ?? 0) + 1;

        if (v['framesDecoded'] != null) {
          decoded = int.tryParse('${v['framesDecoded']}') ?? -1;
          // log(
          //   "[STAT] $tag IN recv=${v['framesReceived']} "
          //       "dec=${v['framesDecoded']} drop=${v['framesDropped']} "
          //       "bytes=${v['bytesReceived']} pli=${v['pliCount']} "
          //       "size=${v['frameWidth']}x${v['frameHeight']}",
          // );
        }
        if (v['framesEncoded'] != null) {
          // log(
          //   "[STAT] $tag OUT enc=${v['framesEncoded']} "
          //       "key=${v['keyFramesEncoded']} sent=${v['framesSent']} "
          //       "bytes=${v['bytesSent']} "
          //       "qlim=${v['qualityLimitationReason']}",
          // );
        }
      }
      // log("[STAT] $tag types=$types");
    } catch (e) {
      log("[STAT] $tag error: $e");
    }
    log("[STAT] $tag end");
    return decoded;
  }

  void _requestKeyframe() {
    final String myUserId = Global.storageServices
        .get(PrefConst.userId)
        .toString();
    String target = (myUserId == callerId.toString()) ? remoteUserId : callerId;
    if (target.isEmpty || target == myUserId) {
      target = (remoteUserId.isNotEmpty && remoteUserId != myUserId)
          ? remoteUserId
          : callerId;
    }
    if (target.isEmpty || target == myUserId) return;

    // log("[CAM] request keyframe from=$target");
    socket?.emit("upgradeToVideo", {
      "callId": callId,
      "remoteUserId": target,
      "callerId": myUserId,
      "needKeyframe": true,
    });
  }

  Future<void> _forceKeyframe() async {
    final List<MediaStreamTrack> vids =
        localStream?.getVideoTracks() ?? <MediaStreamTrack>[];
    if (vids.isEmpty || _localVideoSender == null || !isVideoOn) return;

    // log("[CAM] force keyframe: restart sender at half resolution");
    await _tuneLocalVideoSender(scaleDown: 2.0);
    await _applyLocalVideoSending(null);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    await _applyLocalVideoSending(vids.first);
    _scheduleQualityRestore();
  }

  void _scheduleQualityRestore() {
    _qualityTimer?.cancel();
    _qualityTimer = Timer(const Duration(seconds: 10), () {
      if (isClosed || !isVideoOn) return;
      // log("[CAM] restore full resolution");
      unawaited(_tuneLocalVideoSender(scaleDown: 1.0));
    });
  }

  void _startFirstFrameWatchdog() {
    _firstFrameTimer?.cancel();
    if (!isRemoteVideoOn) {
      isRemoteVideoLoading.value = false;
      return;
    }

    isRemoteVideoLoading.value = true;
    update();

    int decodedFrames = -1;

    _firstFrameTimer = Timer.periodic(const Duration(seconds: 1), (
        timer,
        ) async {
      if (isClosed) {
        timer.cancel();
        return;
      }
      if (!isRemoteVideoOn) {
        timer.cancel();
        isRemoteVideoLoading.value = false;
        update();
        return;
      }

      if (remoteRenderer.value.width > 0) {
        timer.cancel();
        isRemoteVideoLoading.value = false;
        update();
        // log("[CAM] first remote frame arrived w=${remoteRenderer.value.width}");
        return;
      }

      if (timer.tick == 2 || timer.tick == 5 || timer.tick == 9) {
        decodedFrames = await _logStats("wait${timer.tick}s");
        // log(
        //   "[CAM] wait ${timer.tick}s: renderW=${remoteRenderer.value.width} "
        //       "decoded=$decodedFrames",
        // );

        if (decodedFrames > 0) {
          log("[CAM] decoded but no pixels -> rebind #${timer.tick}");
          await _rebindRemoteForFirstFrames(generic: timer.tick >= 9);
        } else {
          log("[CAM] no decoded frames -> request keyframe");
          _requestKeyframe();
        }
      }

      if (timer.tick >= 15) {
        timer.cancel();
        log("[CAM] give up waiting for first frame");
        update();
      }
    });
  }

  void _watchRemoteVideo(String tag) {
    final RTCPeerConnection? pc = peer;
    if (pc == null) return;

    int ticks = 0;
    bool healed = false;

    Timer.periodic(const Duration(seconds: 2), (timer) async {
      ticks++;
      if (isClosed || !identical(peer, pc)) {
        timer.cancel();
        return;
      }

      final int decoded = await _logStats("$tag+${ticks * 2}s");

      if (decoded == 0 && !healed && isRemoteVideoOn) {
        healed = true;
        log("[CAM] no decoded frames after ${ticks * 2}s, rebinding");
        await _rebindRemoteForFirstFrames();
      }

      if (ticks >= 6) timer.cancel();
    });
  }

  void _logRemoteFrameState() {
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (isClosed) return;
      final int w = remoteRenderer.value.width.toInt();
      final int h = remoteRenderer.value.height.toInt();
      log("[CAM] after3s render=${remoteRenderer.renderVideo} size=${w}x$h");
    });
  }

  Future<void> _initializeCall() async {
    try {
      await localRenderer.initialize();
      await remoteRenderer.initialize();

      localRenderer.onFirstFrameRendered = _onRendererFrameEvent;
      remoteRenderer.onFirstFrameRendered = _onRendererFrameEvent;
      localRenderer.onResize = _onRendererFrameEvent;
      remoteRenderer.onResize = _onRendererFrameEvent;

      await _setupPeer();
    } catch (e, stackTrace) {
      log("[Call] Initialization error: $e", stackTrace: stackTrace);
      await _cleanupCall(notifyRemote: true, navigateBack: true);
    }
  }

  Future<void> _cleanupCall({
    required bool notifyRemote,
    required bool navigateBack,
  }) async {
    if (_isCleaningUp) return;
    _isCleaningUp = true;

    final String sessionId = _sessionId;

    try {
      _clearTimers();
      _controlsTimer?.cancel();
      _peerDisconnectTimer?.cancel();

      stopSound();

      if (notifyRemote) {
        _emitEndCallRealtime();
      }

      CallSessionState.reset();

      if (navigateBack) {
        _exitCallScreen();
      }

      await _disposePeerResources();
      await audioRouteController.stopCall();
      await _stopForegroundCallService();

      if (sessionId.isNotEmpty) {
        await CallKitService.dismiss(sessionId);
        try {
          await callEnded(sessionId, type: "CallCleanedUp");
        } catch (e) {
          log("[Call] Call cleanup error: $e");
        }
      }

      await WakelockPlus.disable();
      await ProximityScreenLock.setActive(false);
    } catch (e, stackTrace) {
      log("[Call] General cleanup error: $e", stackTrace: stackTrace);
    } finally {
      _isCleaningUp = false;
    }
  }

  String get _sessionId {
    if (CallSessionState.sessionId != null &&
        CallSessionState.sessionId!.isNotEmpty) {
      return CallSessionState.sessionId!;
    }
    return callId != null ? callId.toString() : "";
  }

  Future<void> _stopForegroundCallService() async {
    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
      }
    } catch (e) {
      log("Error stopping call foreground task: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _ensureAudioTracksActive();
      unawaited(_restoreVideoAfterForeground());
    } else if (state == AppLifecycleState.paused) {
      _keepTracksAliveInBackground();
    }
  }

  Future<void> _restoreVideoAfterForeground() async {
    if (isClosed || !isVideoCall.value) return;
    log(
      "[CAM] resume: restoring video localOn=$isVideoOn "
          "remoteOn=$isRemoteVideoOn",
    );

    if (isVideoOn && localStream != null) {
      final MediaStreamTrack? v = localStream!.getVideoTracks().firstOrNull;
      if (v != null) {
        try {
          await localRenderer.setSrcObject(stream: localStream, trackId: v.id);
        } catch (e) {
          log("[CAM] resume: local rebind failed: $e");
        }
      }
      await _tuneLocalVideoSender();
    }

    if (isRemoteVideoOn) {
      await _rebindRemoteForFirstFrames();
      _startFirstFrameWatchdog();
      _requestKeyframe();
      _watchRemoteVideo("resume");
    }

    update();
  }

  void _ensureAudioTracksActive() {
    try {
      if (localStream != null) {
        for (final MediaStreamTrack track in localStream!.getAudioTracks()) {
          track.enabled = isAudioOn;
        }
        if (isVideoOn) {
          for (final MediaStreamTrack track in localStream!.getVideoTracks()) {
            track.enabled = true;
          }
        }
      }

      final MediaStream? remoteStream =
          _remoteMediaStream ?? remoteRenderer.srcObject;
      if (remoteStream != null) {
        for (final MediaStreamTrack track in remoteStream.getAudioTracks()) {
          track.enabled = true;
        }
        if (isRemoteVideoOn) {
          for (final MediaStreamTrack track in remoteStream.getVideoTracks()) {
            track.enabled = true;
          }
        }
      }

      if (isRemoteVideoOn) {
        unawaited(_ensureRemoteVideoBound());
      }

      unawaited(audioRouteController.restoreCurrentRoute());
    } catch (e) {
      log("Error restoring active WebRTC audio states: $e");
    }
  }

  void _keepTracksAliveInBackground() {
    try {
      if (localStream != null) {
        for (final MediaStreamTrack track in localStream!.getAudioTracks()) {
          track.enabled = isAudioOn;
        }
        for (final MediaStreamTrack track in localStream!.getVideoTracks()) {
          track.enabled = false;
        }
      }
    } catch (e) {
      log("Error keeping background WebRTC audio alive: $e");
    }
  }

  Future<void> _handleRemoteTrack(RTCTrackEvent event) async {
    try {
      final MediaStream? stream = event.streams.isNotEmpty
          ? event.streams.first
          : null;

      if (peer == null) return;

      final bool isVideoTrack = event.track.kind == 'video';

      if (isVideoTrack) {
        if (stream != null) {
          _remoteMediaStream = stream;
        }
        _remoteVideoTrack = event.track;
        _remoteVideoTransceiver = event.transceiver;
        event.track.enabled = true;

        if (!_remoteCamStateKnown) {
          isRemoteVideoOn = true;
        }
        isLocalVideoMain = isRemoteVideoOn ? false : isVideoOn;
        is_video = true;
        isVideoCall.value = true;

        log(
          "[CAM] onTrack video id=${event.track.id} "
              "known=$_remoteCamStateKnown remoteOn=$isRemoteVideoOn",
        );

        log(
          "[CAM] onTrack streams=${event.streams.length} "
              "storedVideo=${_remoteMediaStream?.getVideoTracks().length ?? -1}",
        );

        final MediaStream? targetStream = await _remoteStreamForVideo();
        if (targetStream == null) {
          log("[CAM] bind skipped: no remote video stream available");
        } else {
          log(
            "[CAM] bind remote id=${event.track.id} "
                "stream=${targetStream.id} "
                "tracks=${targetStream.getVideoTracks().length}",
          );
          await remoteRenderer.setSrcObject(
            stream: targetStream,
            trackId: event.track.id,
          );
          _logRemoteFrameState();
          _startFirstFrameWatchdog();
          _watchRemoteVideo("bind");
        }
      } else {
        event.track.enabled = true;
        if (stream != null) {
          _remoteMediaStream ??= stream;
        }
        log(
          "[CAM] onTrack audio id=${event.track.id} "
              "streams=${event.streams.length} "
              "storedVideo=${_remoteMediaStream?.getVideoTracks().length ?? -1}",
        );
      }

      stopSound();
      missedCallTimer?.cancel();
      missedCallTimer = null;

      startCallTimer();
      callStatus.value = "Connected";
      update();

      if (!_audioRouteRestored) {
        _audioRouteRestored = true;
        unawaited(audioRouteController.restoreCurrentRoute());
      }

      if (!_callKitConnectedSent &&
          (fromCallKit || args["callType"] == "Incoming")) {
        _callKitConnectedSent = true;
        unawaited(CallKitService.setConnected(_sessionId));
      }
    } catch (e, stackTrace) {
      log("[Call] onTrack error: $e", stackTrace: stackTrace);
    }
  }

  void _emitUpgradeIntent() {
    final String myUserId = Global.storageServices
        .get(PrefConst.userId)
        .toString();
    String target = (myUserId == callerId.toString()) ? remoteUserId : callerId;
    if (target.isEmpty || target == myUserId) {
      target = (remoteUserId.isNotEmpty && remoteUserId != myUserId)
          ? remoteUserId
          : callerId;
    }
    if (target.isEmpty || target == myUserId) return;

    // log("[CAM] announce upgrade intent to=$target");
    socket?.emit("requestVideoUpgrade", {
      "callId": callId,
      "remoteUserId": target,
      "callerId": myUserId,
    });
  }

  void _markRemoteUpgrading(String source) {
    if (isUpgradingToVideo.value) return;
    isRemoteUpgrading.value = true;
    // log("[CAM] remote upgrading ($source) -> video button disabled");
    _remoteUpgradeTimer?.cancel();
    _remoteUpgradeTimer = Timer(const Duration(seconds: 20), () {
      if (isClosed) return;
      isRemoteUpgrading.value = false;
      log("[CAM] remote upgrade flag cleared (timeout)");
      update();
    });
    update();
  }

  void _clearRemoteUpgrading() {
    if (!isRemoteUpgrading.value) return;
    _remoteUpgradeTimer?.cancel();
    _remoteUpgradeTimer = null;
    isRemoteUpgrading.value = false;
    log("[CAM] remote upgrade flag cleared");
    update();
  }

  Future<void> upgradeToVideoCall() async {
    if (isUpgradingToVideo.value) return;
    if (isRemoteUpgrading.value) {
      // log("[CAM] upgrade blocked: remote is already upgrading");
      Utils().fluttertoast("The other person is starting video");
      return;
    }
    if (peer == null || localStream == null) {
      Utils().fluttertoast("Call not ready");
      return;
    }
    _emitUpgradeIntent();

    try {
      isUpgradingToVideo.value = true;
      // log(
      //   "[CAM] upgrade start videoOn=$isVideoOn remoteOn=$isRemoteVideoOn "
      //       "sender=${_localVideoSender != null} slotReady=$_videoSlotReady",
      // );
      if (!isVideoCall.value) {
        pipPosition = null;
        await audioRouteController.updateCallType(isVideo: true);
      }

      final bool needsRenegotiation = await _ensureLocalVideoTrackAttached(
        peer!,
      );
      // log(
      //   "[CAM] upgrade attach done sender=${_localVideoSender != null} "
      //       "slotReady=$_videoSlotReady needsReneg=$needsRenegotiation",
      // );

      isVideoOn = true;
      isLocalVideoMain = !isRemoteVideoOn;

      await _tuneLocalVideoSender(scaleDown: 2.0);
      _scheduleQualityRestore();

      if (needsRenegotiation || !_videoSlotReady) {
        log("[CAM] upgrade: renegotiating (video m-line not signalled)");
        await _renegotiateVideo();
      } else {
        log("[CAM] upgrade: slot live, no renegotiation needed");
      }

      _emitCameraState(true);
      _clearRemoteUpgrading();
      await _syncVideoState();

      if (callTimer == null && callDurationSeconds == 0) {
        callStatus.value = "Video connecting";
      }
      update();
    } catch (e) {
      log("upgradeToVideoCall error: $e");
    } finally {
      isUpgradingToVideo.value = false;
    }
  }

  void _listenVideoUpgradeEvents() {
    socket?.off("upgradeToVideo");
    socket?.off("upgradeToVideoAnswer");
    socket?.off("requestVideoUpgrade");

    socket?.on("requestVideoUpgrade", (data) {
      final String from = data["callerId"]?.toString() ?? "";
      log("[CAM] requestVideoUpgrade from=$from");
      _markRemoteUpgrading("intent");
    });

    socket?.on("upgradeToVideo", (data) async {
      try {
        final RTCPeerConnection? pc = peer;
        if (pc == null) return;
        final dynamic sdp = data["sdpOffer"];
        log(
          "[CAM] upgradeToVideo recv hasSdp=${sdp != null} "
              "cameraState=${data["cameraState"]} from=${data["callerId"]} "
              "videoOn=$isVideoOn remoteOn=$isRemoteVideoOn",
        );

        if (sdp != null && !_localOfferPending) {
          _markRemoteUpgrading("offer");
        }

        if (sdp == null) {
          if (data["needKeyframe"] == true) {
            await _forceKeyframe();
            return;
          }

          final dynamic state = data["cameraState"];
          if (state is bool) {
            final bool wasRemoteVideoOn = isRemoteVideoOn;
            _remoteCamStateKnown = true;
            isRemoteVideoOn = state;
            log("[CAM] recv cameraState=$state from=${data["callerId"]}");
            _clearRemoteUpgrading();
            if (!wasRemoteVideoOn && isRemoteVideoOn) {
              isLocalVideoMain = false;
              await _rebindRemoteForFirstFrames();
              _startFirstFrameWatchdog();
              _watchRemoteVideo("camOn");
            } else if (!state && isVideoOn) {
              isLocalVideoMain = true;
            }
            await _syncVideoState();
          }
          return;
        }

        if (_localOfferPending) {
          final String myId = Global.storageServices
              .get(PrefConst.userId)
              .toString();
          final String peerId = data["callerId"]?.toString() ?? "";
          final bool polite = myId.compareTo(peerId) > 0;
          log("[CAM] glare offer from=$peerId polite=$polite");

          if (!polite) {
            log("[CAM] glare: ignoring incoming offer, our offer wins");
            return;
          }

          try {
            await pc.setLocalDescription(RTCSessionDescription('', 'rollback'));
            log("[CAM] glare: rolled back our offer");
          } catch (e) {
            log("[CAM] glare rollback failed: $e");
          }
          _localOfferPending = false;
          _renegotiating = false;
          _pendingRenegotiation = false;
        }

        final bool? remoteCam = _camStateFromSdp(sdp["sdp"]?.toString() ?? '');
        final bool remoteSendingVideo = remoteCam ?? isRemoteVideoOn;
        if (remoteCam != null) {
          _remoteCamStateKnown = true;
        }

        if (!isVideoCall.value && remoteSendingVideo) {
          await audioRouteController.updateCallType(isVideo: true);
        }

        await _applyRemoteSdp(pc, sdp);

        isRemoteVideoOn = remoteSendingVideo;
        if (isRemoteVideoOn) {
          isLocalVideoMain = isVideoOn ? isLocalVideoMain : false;
        } else if (isVideoOn) {
          isLocalVideoMain = true;
        }

        if (_localVideoSender == null && !isVideoOn) {
          try {
            final bool answerNeedsReneg = await _ensureLocalVideoTrackAttached(
              pc,
              muted: true,
            );
            log(
              "[CAM] answer: muted video track attached before answer "
                  "(reneg=$answerNeedsReneg)",
            );
          } catch (e) {
            log("[CAM] answer: muted attach failed: $e");
          }
        }

        bool slotAdvertised = false;
        try {
          final RTCRtpTransceiver? slot = _remoteVideoTransceiver;
          if (slot != null) {
            await slot.setDirection(TransceiverDirection.SendRecv);
            slotAdvertised = true;
            log("[CAM] answer: video slot advertised sendrecv");
          } else {
            log("[CAM] answer: no video transceiver captured yet");
          }
        } catch (e) {
          log("[CAM] answer: setDirection failed: $e");
        }

        RTCSessionDescription rawAnswer;
        try {
          rawAnswer = await pc.createAnswer({
            'offerToReceiveAudio': true,
            'offerToReceiveVideo': true,
          });
        } catch (e) {
          log("[CAM] answer: createAnswer failed with sendrecv: $e");
          if (slotAdvertised) {
            try {
              await _remoteVideoTransceiver?.setDirection(
                TransceiverDirection.RecvOnly,
              );
            } catch (_) {}
            slotAdvertised = false;
          }
          rawAnswer = await pc.createAnswer({
            'offerToReceiveAudio': true,
            'offerToReceiveVideo': true,
          });
        }

        final RTCSessionDescription answer = RTCSessionDescription(
          _withCamTag(_preferH264InSdp(rawAnswer.sdp ?? ''), isVideoOn),
          rawAnswer.type,
        );
        await pc.setLocalDescription(answer);
        log(
          "[SDP] answer ${_sdpInfo(answer.sdp)} "
              "slotAdvertised=$slotAdvertised",
        );

        if (slotAdvertised) {
          try {
            final TransceiverDirection? current = await _remoteVideoTransceiver
                ?.getCurrentDirection();
            _videoSlotReady =
                current == TransceiverDirection.SendRecv ||
                    current == TransceiverDirection.SendOnly;
          } catch (_) {
            _videoSlotReady = false;
          }
          log("[CAM] answer: slotReady=$_videoSlotReady");
        }

        if (isVideoOn) {
          await _tuneLocalVideoSender();
        }

        socket?.emit("upgradeToVideoAnswer", {
          "callId": callId,
          "remoteUserId": data["callerId"],
          "sdpAnswer": answer.toMap(),
        });
        _clearRemoteUpgrading();

        callStatus.value = "Connected";
        await _syncVideoState();
      } catch (e) {
        log("upgradeToVideo handler error: $e");
      }
    });

    socket?.on("upgradeToVideoAnswer", (data) async {
      try {
        final RTCPeerConnection? pc = peer;
        if (pc == null) return;
        final dynamic sdp = data["sdpAnswer"];
        log(
          "[CAM] upgradeToVideoAnswer recv hasSdp=${sdp != null} "
              "pending=$_localOfferPending",
        );
        if (sdp == null) return;

        if (!_localOfferPending) {
          log("[CAM] ignoring answer: no local offer pending");
          return;
        }
        _localOfferPending = false;

        final bool? remoteCam = _camStateFromSdp(sdp["sdp"]?.toString() ?? '');
        final bool remoteSendingVideo = remoteCam ?? isRemoteVideoOn;
        if (remoteCam != null) {
          _remoteCamStateKnown = true;
        }

        await _applyRemoteSdp(pc, sdp);

        isRemoteVideoOn = remoteSendingVideo;
        if (isRemoteVideoOn) {
          isLocalVideoMain = isVideoOn ? isLocalVideoMain : false;
        } else if (isVideoOn) {
          isLocalVideoMain = true;
        }

        if (isVideoOn) {
          await _tuneLocalVideoSender();
        }

        callStatus.value = "Connected";
        await _syncVideoState();
      } catch (e) {
        log("upgradeToVideoAnswer error: $e");
      }
    });
  }

  void _onNewCall(dynamic data) {
    socket?.emit("CallingStatus", {
      "callId": data['callId'].toString(),
      "remoteUserId": int.tryParse(data['callerId'].toString()) ?? 0,
      "callingStatus": "Ringing",
    });
  }

  Future<void> _onCallEnded(dynamic data) async {
    log("[Socket] callEnded RECEIVED: $data");
    Utils().fluttertoast('Call Ended By ${args["callerName"] ?? "Unknown"}');
    await _cleanupCall(notifyRemote: false, navigateBack: true);
  }

  Future<void> _onMissedCall(dynamic data) async {
    if (_isCleaningUp) return;

    if (callTimer != null || callDurationSeconds > 0) {
      return;
    }

    _isCleaningUp = true;
    try {
      _clearTimers();
      stopSound();

      final String sessionId = data["sessionId"]?.toString().isNotEmpty == true
          ? data["sessionId"].toString()
          : _sessionId;

      CallSessionState.reset();
      _exitCallScreen();

      await resetPeer();
      await audioRouteController.stopCall();

      if (sessionId.isNotEmpty) {
        await CallKitService.dismiss(sessionId);
        await callEnded(sessionId, type: "missedCallFromSocket");
      }

      await _stopForegroundCallService();
      await WakelockPlus.disable();
      await ProximityScreenLock.setActive(false);
    } finally {
      _isCleaningUp = false;
    }
  }

  void _onCallCreated(dynamic data) {
    try {
      if (data['callId'] != null) callId = data['callId'];
      final sid = data['sessionId'] ?? data['session_id'];
      if (sid != null && sid.toString().isNotEmpty) {
        CallSessionState.sessionId = sid.toString();
      }
    } catch (e) {
      log("[Call] callCreated parse error: $e");
    }
  }

  void _listenForCallEvents() {
    socket?.off("callRejected");
    socket?.off("callEnded", _onCallEnded);
    socket?.off("endCall", _onCallEnded);
    socket?.off("missedCall", _onMissedCall);
    socket?.off("callStatus");
    socket?.off("callCreated");
    socket?.off("newCall", _onNewCall);
    socket?.off("sdpOfferFromCaller");
    socket?.off("callError");
    socket?.off("callBlocked");

    socket?.on("callCreated", _onCallCreated);

    socket?.on("callError", (data) async {
      log("CALL ERROR => $data");
      await _cleanupCall(notifyRemote: false, navigateBack: true);
      Get.snackbar(
        "Call Failed",
        data?["message"]?.toString() ?? "Unable to make call",
      );
    });

    socket?.on("callBlocked", (data) async {
      log("CALL BLOCKED => $data");
      await _cleanupCall(notifyRemote: false, navigateBack: true);
      Get.snackbar(
        "Call unavailable",
        data?["message"]?.toString() ??
            "Communication is not available with this user",
      );
    });

    socket?.on("sdpOfferFromCaller", (data) async {
      final RTCPeerConnection? pc = peer;
      if (pc == null) return;

      try {
        final dynamic sdp = data["sdpOffer"] ?? data["offer"];
        if (sdp == null) return;
        offer = sdp;
        callId = data["callId"] ?? callId;

        pc.onIceCandidate = (c) {
          if (c.candidate == null) return;
          socket!.emit("IceCandidate", {
            "remoteUserId": callerId,
            "iceCandidate": {
              "id": c.sdpMid,
              "label": c.sdpMLineIndex,
              "candidate": c.candidate,
            },
          });
        };

        await _applyRemoteSdp(pc, sdp);

        final RTCSessionDescription rawAnswer = await pc.createAnswer({
          'offerToReceiveAudio': true,
          'offerToReceiveVideo': true,
        });
        final RTCSessionDescription answer = RTCSessionDescription(
          _withCamTag(_preferH264InSdp(rawAnswer.sdp ?? ''), isVideoOn),
          rawAnswer.type,
        );
        await pc.setLocalDescription(answer);
        log("[SDP] callkit answer ${_sdpInfo(answer.sdp)}");

        socket!.emit("answerCall", {
          "callId": callId,
          "callerId": callerId,
          "sdpAnswer": answer.toMap(),
        });
        if (callTimer == null && callDurationSeconds == 0) {
          callStatus.value = "Connecting";
        }
      } catch (e) {
        log("Error handling sdpOfferFromCaller: $e");
      }
    });

    socket?.on("newCall", _onNewCall);
    socket?.on("callEnded", _onCallEnded);
    socket?.on("endCall", _onCallEnded);
    socket?.on("missedCall", _onMissedCall);

    socket?.on("callRejected", (data) async {
      if (callTimer != null || callDurationSeconds > 0) {
        return;
      }

      Utils().fluttertoast(
        'Call Rejected By ${args["callerName"] ?? "Unknown"}',
        bgColor: Colors.red,
      );
      await _cleanupCall(notifyRemote: false, navigateBack: true);
    });

    socket?.on("callStatus", (data) {
      final status = (data["status"] ?? data["callingStatus"])?.toString();
      if (status == null || status.isEmpty) return;

      if (data['callId'] != null) {
        callId = data['callId'];
      }

      final String normalized = status.trim().toLowerCase();
      if (normalized == "rejected" || normalized == "declined") {
        if (callTimer == null && callDurationSeconds == 0) {
          Utils().fluttertoast(
            'Call Rejected By ${args["callerName"] ?? "Unknown"}',
            bgColor: Colors.red,
          );
          unawaited(_cleanupCall(notifyRemote: false, navigateBack: true));
          return;
        }
      } else if (normalized == "ended" ||
          normalized == "callended" ||
          normalized == "disconnected" ||
          normalized == "cancelled" ||
          normalized == "canceled") {
        unawaited(_cleanupCall(notifyRemote: false, navigateBack: true));
        return;
      }

      if (callTimer == null && callDurationSeconds == 0) {
        callStatus.value = status;
      }
    });

    _listenVideoUpgradeEvents();
  }

  Future<void> resetPeer() async {
    await _disposePeerResources();
  }

  Future<void> _disposePeerResources() async {
    try {
      _peerDisconnectTimer?.cancel();
      _peerDisconnectTimer = null;

      navigator.mediaDevices.ondevicechange = null;

      final RTCPeerConnection? pc = peer;
      peer = null;
      _localVideoSender = null;
      _remoteMediaStream = null;
      _remoteVideoTrack = null;
      _remoteCamStateKnown = false;
      _remoteVideoTransceiver = null;
      _videoSlotReady = false;
      _fallbackRemoteStream = null;
      _remoteDescriptionSet = false;
      _audioRouteRestored = false;
      _renegotiating = false;
      _pendingRenegotiation = false;
      _localOfferPending = false;
      isRemoteUpgrading.value = false;
      _remoteUpgradeTimer?.cancel();
      isRemoteVideoOn = false;
      isRemoteVideoLoading.value = false;
      _pendingRemoteCandidates.clear();

      if (pc != null) {
        pc.onIceConnectionState = null;
        pc.onConnectionState = null;
        pc.onSignalingState = null;
        pc.onTrack = null;
        pc.onIceCandidate = null;
      }

      localStream?.getTracks().forEach((track) {
        track.stop();
      });

      await localStream?.dispose();
      localStream = null;

      remoteRenderer.srcObject = null;
      localRenderer.srcObject = null;

      await pc?.close();

      socket?.off("IceCandidate");
      socket?.off("callAnswered");
    } catch (e, stackTrace) {
      log("[Call] Peer dispose error: $e", stackTrace: stackTrace);
    }
  }

  void safeAddCandidate(dynamic data) {
    try {
      final ice = data["iceCandidate"];
      if (ice == null) return;

      if (peer == null || !_remoteDescriptionSet) {
        _pendingRemoteCandidates.add(data);
        return;
      }

      final c = RTCIceCandidate(ice["candidate"], ice["id"], ice["label"]);

      unawaited(
        peer!.addCandidate(c).catchError((e) {
          log("[Call] addCandidate error: $e");
        }),
      );
    } catch (e) {
      log("[Call] safeAddCandidate error: $e");
    }
  }

  Future<void> _markRemoteDescriptionSet() async {
    _remoteDescriptionSet = true;

    if (_pendingRemoteCandidates.isEmpty) return;

    final List<dynamic> pending = List<dynamic>.from(_pendingRemoteCandidates);
    _pendingRemoteCandidates.clear();

    for (final d in pending) {
      safeAddCandidate(d);
    }
  }

  void _startPeerDisconnectTimer({
    Duration grace = const Duration(seconds: 30),
  }) {
    if (_peerDisconnectTimer?.isActive ?? false) return;

    if (_everConnected && !_isCleaningUp && !isClosed) {
      callStatus.value = "Reconnecting...";
      update();
    }

    _peerDisconnectTimer = Timer(grace, () {
      final RTCIceConnectionState? ice = peer?.iceConnectionState;
      final RTCPeerConnectionState? conn = peer?.connectionState;

      final bool recovered =
          ice == RTCIceConnectionState.RTCIceConnectionStateConnected ||
              ice == RTCIceConnectionState.RTCIceConnectionStateCompleted ||
              conn == RTCPeerConnectionState.RTCPeerConnectionStateConnected;

      if (recovered) return;

      _handlePeerDisconnected();
    });
  }

  void _cancelPeerDisconnectTimer() {
    final bool wasWaiting = _peerDisconnectTimer?.isActive ?? false;
    _peerDisconnectTimer?.cancel();
    _peerDisconnectTimer = null;

    if (wasWaiting && callStatus.value == "Reconnecting...") {
      callStatus.value = "Connected";
      update();
    }
  }

  Future<void> _setupPeer() async {
    await resetPeer();

    if (socket == null) {
      throw Exception("Socket is not initialized");
    }

    socket!.off("IceCandidate");
    socket!.off("callAnswered");

    socket!.on("IceCandidate", (data) {
      safeAddCandidate(data);
    });

    final RTCPeerConnection pc = await createPeerConnection({
      'sdpSemantics': 'unified-plan',
      'iceServers': [
        {
          'urls': ['stun:stun.l.google.com:19302'],
        },
        {
          'urls': Urls.rtcUrl,
          'username': Urls.rtcUserName,
          'credential': Urls.rtcCredential,
        },
      ],
      'iceTransportPolicy': 'all',
    });
    peer = pc;

    pc.onIceConnectionState = (state) {
      if (!identical(peer, pc)) return;
      log("[Call] ICE state: $state");

      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        _everConnected = true;
        _cancelPeerDisconnectTimer();
        missedCallTimer?.cancel();
        missedCallTimer = null;
        return;
      }

      if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
        _startPeerDisconnectTimer();
        return;
      }

      if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        _startPeerDisconnectTimer(grace: const Duration(seconds: 12));
        return;
      }

      if (state == RTCIceConnectionState.RTCIceConnectionStateClosed) {
        return;
      }
    };

    pc.onConnectionState = (state) {
      if (!identical(peer, pc)) return;
      log("[Call] Peer connection state: $state");

      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _everConnected = true;
        _cancelPeerDisconnectTimer();
        return;
      }

      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        _startPeerDisconnectTimer(grace: const Duration(seconds: 12));
        return;
      }

      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        _startPeerDisconnectTimer();
      }
    };

    pc.onTrack = (event) {
      if (!identical(peer, pc)) return;
      unawaited(_handleRemoteTrack(event));
    };

    localStream = await navigator.mediaDevices.getUserMedia({
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': is_video == true ? _videoCaptureConstraints() : false,
    });

    for (final MediaStreamTrack t in localStream!.getTracks()) {
      final RTCRtpSender sender = await pc.addTrack(t, localStream!);
      if (t.kind == 'video') {
        _localVideoSender = sender;
      }
    }

    if (is_video == true) {
      _logCaptureSettings("setup");
      await _tuneLocalVideoSender();
      final MediaStreamTrack? vidTrack = localStream!
          .getVideoTracks()
          .firstOrNull;
      if (vidTrack != null) {
        await localRenderer.setSrcObject(
          stream: localStream,
          trackId: vidTrack.id,
        );
      } else {
        localRenderer.srcObject = localStream;
      }
    } else {
      localRenderer.srcObject = null;
    }

    unawaited(
      audioRouteController.startCall(isVideo: is_video).catchError((e) {
        log("[Call] Audio route start error: $e");
      }),
    );

    update();

    if (offer != null) {
      pc.onIceCandidate = (c) {
        if (c.candidate == null) return;
        socket!.emit("IceCandidate", {
          "remoteUserId": callerId,
          "iceCandidate": {
            "id": c.sdpMid,
            "label": c.sdpMLineIndex,
            "candidate": c.candidate,
          },
        });
      };

      await _applyRemoteSdp(pc, offer);

      final RTCSessionDescription rawAnswer = await pc.createAnswer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      final RTCSessionDescription answer = RTCSessionDescription(
        _withCamTag(_preferH264InSdp(rawAnswer.sdp ?? ''), isVideoOn),
        rawAnswer.type,
      );
      await pc.setLocalDescription(answer);
      log("[SDP] initial answer ${_sdpInfo(answer.sdp)}");

      socket!.emit("answerCall", {
        "callId": callId,
        "callerId": callerId,
        "sdpAnswer": answer.toMap(),
      });
    } else if (fromCallKit ||
        (args["callType"] == "Incoming" && offer == null)) {
      callStatus.value = "Connecting...";
      final acceptPayload = {
        "callerId": callerId,
        "sessionId": CallSessionState.sessionId ?? args["sessionId"],
        "callId": callId,
        "receiverId": Global.storageServices.get(PrefConst.userId),
      };
      socket!.emit("acceptCallFromCallKit", acceptPayload);
    } else {
      pc.onIceCandidate = (c) => iceCandidates.add(c);

      socket!.on("callAnswered", (data) async {
        if (!identical(peer, pc) || _remoteDescriptionSet) return;

        stopSound();
        missedCallTimer?.cancel();
        missedCallTimer = null;

        try {
          await _applyRemoteSdp(pc, data["sdpAnswer"]);
          if (isVideoCall.value && isVideoOn) {
            await _tuneLocalVideoSender();
          }
        } catch (e) {
          log("[Call] callAnswered handler error: $e");
          return;
        }

        for (final c in iceCandidates) {
          if (c.candidate == null) continue;
          socket!.emit("IceCandidate", {
            "remoteUserId": remoteUserId,
            "iceCandidate": {
              "id": c.sdpMid,
              "label": c.sdpMLineIndex,
              "candidate": c.candidate,
            },
          });
        }
        iceCandidates.clear();

        pc.onIceCandidate = (c) {
          if (c.candidate == null) return;
          socket!.emit("IceCandidate", {
            "remoteUserId": remoteUserId,
            "iceCandidate": {
              "id": c.sdpMid,
              "label": c.sdpMLineIndex,
              "candidate": c.candidate,
            },
          });
        };
      });

      final RTCSessionDescription rawOffer = await pc.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      final RTCSessionDescription sdpOffer = RTCSessionDescription(
        _withCamTag(_preferH264InSdp(rawOffer.sdp ?? ''), isVideoOn),
        rawOffer.type,
      );
      await pc.setLocalDescription(sdpOffer);
      log("[SDP] initial offer ${_sdpInfo(sdpOffer.sdp)}");

      socket!.emit("makeCall", {
        "remoteUserId": remoteUserId,
        "sdpOffer": sdpOffer.toMap(),
        "is_video": is_video,
        "callerId": Global.storageServices.get(PrefConst.userId),
      });

      startMissedCallTimer();
    }
  }

  Future<void> endCall({String? type}) async {
    if (_isCleaningUp) return;
    _isCleaningUp = true;

    final String sid = _sessionId;

    try {
      _clearTimers();
      stopSound();

      _emitEndCallRealtime();

      CallSessionState.reset();
      _exitCallScreen();

      await resetPeer();
      await audioRouteController.stopCall();
      await _stopForegroundCallService();

      if (sid.isNotEmpty) {
        await CallKitService.dismiss(sid);
        await callEnded(
          sid,
          type: "endCallMethodHittedFromController-Type:$type",
        );
      }

      await WakelockPlus.disable();
      await ProximityScreenLock.setActive(false);
    } finally {
      _isCleaningUp = false;
    }
  }

  void _handlePeerDisconnected() {
    if (_isCleaningUp || isClosed) return;
    unawaited(_cleanupCall(notifyRemote: true, navigateBack: true));
  }

  void toggleMic() {
    isAudioOn = !isAudioOn;
    localStream?.getAudioTracks().forEach((t) => t.enabled = isAudioOn);
    update();
  }

  void _emitCameraState(bool cameraOn) {
    final String myUserId = Global.storageServices
        .get(PrefConst.userId)
        .toString();
    String targetUser = (myUserId == callerId.toString())
        ? remoteUserId
        : callerId;

    if (targetUser.isEmpty || targetUser == myUserId) {
      targetUser = (remoteUserId.isNotEmpty && remoteUserId != myUserId)
          ? remoteUserId
          : callerId;
    }
    if (targetUser.isEmpty || targetUser == myUserId) {
      log(
        "[CAM] no peer for cameraState=$cameraOn "
            "(callerId=$callerId remoteUserId=$remoteUserId)",
      );
      return;
    }

    log("[CAM] send cameraState=$cameraOn to=$targetUser");

    socket?.emit("upgradeToVideo", {
      "callId": callId,
      "remoteUserId": targetUser,
      "callerId": myUserId,
      "cameraState": cameraOn,
    });
  }

  Future<void> toggleCamera() async {
    final RTCPeerConnection? pc = peer;
    if (pc == null) return;

    final List<MediaStreamTrack> vids =
        localStream?.getVideoTracks() ?? <MediaStreamTrack>[];
    if (vids.isEmpty) {
      await upgradeToVideoCall();
      return;
    }

    isVideoOn = !isVideoOn;
    for (final MediaStreamTrack t in vids) {
      t.enabled = isVideoOn;
    }
    log(
      "[CAM] toggle -> on=$isVideoOn tracks=${vids.length} "
          "sender=${_localVideoSender != null} slotReady=$_videoSlotReady",
    );

    if (isVideoOn) {
      if (localStream != null) {
        await localRenderer.setSrcObject(
          stream: localStream,
          trackId: vids.first.id,
        );
      }
      if (!isRemoteVideoOn) {
        isLocalVideoMain = true;
      }
    } else if (isRemoteVideoOn) {
      isLocalVideoMain = false;
    }
    update();

    _emitCameraState(isVideoOn);

    try {
      await _applyLocalVideoSending(isVideoOn ? vids.first : null);
      log("[CAM] toggle applied replaceTrack=${isVideoOn ? 'track' : 'null'}");
      if (isVideoOn) {
        await _tuneLocalVideoSender();
      }
      await _syncVideoState();
    } catch (e) {
      log("[Call] toggleCamera error: $e");
    }
  }

  Future<void> switchCamera() async {
    if (_isSwitchingCamera || !isVideoCall.value || !isVideoOn) return;
    final List<MediaStreamTrack> tracks =
        localStream?.getVideoTracks() ?? <MediaStreamTrack>[];
    if (tracks.isEmpty) return;

    _isSwitchingCamera = true;
    showControlsTemporarily();
    try {
      for (final MediaStreamTrack t in tracks) {
        await Helper.switchCamera(t);
      }
      isFrontCamera = !isFrontCamera;
      update();
    } catch (e) {
      log("[Call] switchCamera error: $e");
    } finally {
      _isSwitchingCamera = false;
    }
  }

  Future<void> toggleSpeaker(BuildContext context) async {
    showAudioRoutePicker(context);
  }

  Future<void> showAudioRoutePicker(BuildContext context) async {
    if (!context.mounted) return;

    await audioRouteController.checkDevices();
    if (!context.mounted) return;

    final CallAudioRoute? selected = await showAudioRouteSheet(
      context,
      audioRouteController,
    );

    if (selected != null) {
      await audioRouteController.selectRoute(selected);
    }
  }

  String get formattedDuration {
    final int secs = callDurationRx.value;
    final minutes = (secs ~/ 60).toString().padLeft(2, '0');
    final seconds = (secs % 60).toString().padLeft(2, '0');
    if (Utility.isNotNullEmptyOrFalse("$minutes:$seconds")) {
      if (args["callType"] == "outGoing") {
        stopSound();
      }
    }
    return "$minutes:$seconds";
  }

  void startCallTimer() {
    if (callTimer != null) return;
    callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      callDurationSeconds++;
      callDurationRx.value = callDurationSeconds;
      if (!isVideoCall.value) {
        update();
      }
    });
  }

  void startMissedCallTimer() {
    missedCallTimer?.cancel();
    missCallDurationSeconds.value = 40;
    missedCallTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      if (missCallDurationSeconds.value > 0) {
        missCallDurationSeconds.value--;
      }
      if (missCallDurationSeconds.value == 0) {
        timer.cancel();
        missedCall();
      }
    });
  }

  Future<void> missedCall() async {
    final Map<String, dynamic> param = {
      "callId": callId,
      "remoteUserId": remoteUserId,
    };

    socket?.emit("missCall", param);

    await endCall(type: "missedCall");
  }

  void _clearTimers() {
    callTimer?.cancel();
    missedCallTimer?.cancel();
    _firstFrameTimer?.cancel();
    _qualityTimer?.cancel();
    _remoteUpgradeTimer?.cancel();
    callTimer = null;
    missedCallTimer = null;
    _firstFrameTimer = null;
    _qualityTimer = null;
    missCallDurationSeconds.value = 0;
  }

  void playSound() {
    FlutterRingtonePlayer().play(
      asAlarm: false,
      fromAsset: Assets.music.ringing,
      looping: true,
      volume: 1.0,
    );
  }

  void stopSound() {
    FlutterRingtonePlayer().stop();
  }

  Future<void> startAudioCall() async {
    await WakelockPlus.enable();

    if (!audioRouteController.isBluetoothConnected.value) {
      await ProximityScreenLock.setActive(true);
    }
  }

  Future<void> endAudioCall() async {
    await WakelockPlus.disable();
    await ProximityScreenLock.setActive(false);
  }

  void updatePipPosition({
    required Offset delta,
    required double pipWidth,
    required double pipHeight,
    required double minLeft,
    required double maxLeft,
    required double minTop,
    required double maxTop,
  }) {
    final Offset currentPosition = pipPosition ?? Offset(minLeft, maxTop);
    final double boundedMaxLeft = maxLeft < minLeft ? minLeft : maxLeft;
    final double boundedMaxTop = maxTop < minTop ? minTop : maxTop;

    pipPosition = Offset(
      (currentPosition.dx + delta.dx).clamp(minLeft, boundedMaxLeft),
      (currentPosition.dy + delta.dy).clamp(minTop, boundedMaxTop),
    );
    update();
  }

  @override
  void onClose() {
    _isCleaningUp = true;

    WidgetsBinding.instance.removeObserver(this);

    _peerDisconnectTimer?.cancel();
    _controlsTimer?.cancel();

    stopSound();

    navigator.mediaDevices.ondevicechange = null;

    socket?.off("IceCandidate");
    socket?.off("callAnswered");
    socket?.off("upgradeToVideo");
    socket?.off("upgradeToVideoAnswer");
    socket?.off("callRejected");
    socket?.off("callEnded", _onCallEnded);
    socket?.off("endCall", _onCallEnded);
    socket?.off("missedCall", _onMissedCall);
    socket?.off("callStatus");
    socket?.off("callCreated", _onCallCreated);
    socket?.off("newCall", _onNewCall);
    socket?.off("sdpOfferFromCaller");
    socket?.off("callError");
    socket?.off("callBlocked");

    unawaited(_disposePeerResources());
    unawaited(_stopForegroundCallService());
    unawaited(audioRouteController.stopCall());

    if (Get.isRegistered<CallAudioRouteController>(tag: _audioRouteTag)) {
      Get.delete<CallAudioRouteController>(tag: _audioRouteTag);
    }

    _clearTimers();

    final sid = _sessionId;
    if (sid.isNotEmpty) {
      unawaited(callEnded(sid, type: "onClose"));
    }

    CallSessionState.reset();

    WakelockPlus.disable();
    ProximityScreenLock.setActive(false);

    super.onClose();
  }
}
