import 'dart:developer';
import 'dart:math' show Random, max;

import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/widgets.dart' show AppLifecycleState, WidgetsBinding;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../Data/Repositories/attendance_repo.dart';
import '../../../Data/Services/Socket/Socket_Message_Services.dart'
    show SocketMessageService;
import '../models/attendance_poll_model.dart';

class AttendanceLocationFix {
  final Position position;
  final String? placeName;
  const AttendanceLocationFix(this.position, this.placeName);
}

class AttendanceVotersPage {
  final List<AttendanceVoter> voters;
  final int total;
  final Map<String, int> countsByOption;
  final int notVoted;
  final bool hasNext;

  const AttendanceVotersPage({
    required this.voters,
    required this.total,
    required this.countsByOption,
    required this.notVoted,
    required this.hasNext,
  });
}

/// Shared store for attendance polls. Chat cards and the detail screen read
/// [polls] by pollId so REST responses and socket events update them in place.
class AttendanceController extends GetxController {
  static AttendanceController get instance =>
      Get.isRegistered<AttendanceController>()
          ? Get.find<AttendanceController>()
          : Get.put(AttendanceController(), permanent: true);

  final RxMap<int, AttendancePoll> polls = <int, AttendancePoll>{}.obs;
  final Set<int> _loading = {};
  final Set<int> _loaded = {};
  final Random _random = Random();

  SocketMessageService get _socket => SocketMessageService.instance;

  // ---- Live fallback -------------------------------------------------------
  // Socket events are the primary live channel. If they don't arrive (missed
  // room join, backend not emitting), polls on screen are refetched every
  // [_fallbackInterval] so votes still show up live. A poll that got a socket
  // update within [_socketFreshFor] is skipped, so a working socket means
  // (almost) no extra requests.
  static const _fallbackInterval = Duration(seconds: 5);
  static const _socketFreshFor = Duration(seconds: 15);
  final Map<int, int> _watchers = {};
  final Map<int, DateTime> _lastLiveAt = {};
  final Set<int> _pendingMutations = {};
  Timer? _fallbackTimer;

  /// True once a live attendance event has arrived over the socket in this
  /// session, i.e. the realtime path works. While it holds and the socket is
  /// connected, the fallback refresh is skipped (no idle polling).
  bool _socketProven = false;

  /// Called by widgets showing a poll (chat card, View Attendance).
  void watch(int pollId) {
    if (pollId <= 0) return;
    _watchers[pollId] = (_watchers[pollId] ?? 0) + 1;
    _fallbackTimer ??= Timer.periodic(_fallbackInterval, (_) => _fallbackTick());
  }

  void unwatch(int pollId) {
    final count = (_watchers[pollId] ?? 0) - 1;
    if (count > 0) {
      _watchers[pollId] = count;
    } else {
      _watchers.remove(pollId);
    }
    if (_watchers.isEmpty) {
      _fallbackTimer?.cancel();
      _fallbackTimer = null;
    }
  }

  void _fallbackTick() {
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    if (_socketProven && _socket.isSocketConnected) return;
    final now = DateTime.now();
    for (final pollId in _watchers.keys.toList()) {
      final poll = polls[pollId];
      if (poll != null && poll.isClosed) continue;
      if (_pendingMutations.contains(pollId)) continue;
      final last = _lastLiveAt[pollId];
      if (last != null && now.difference(last) < _socketFreshFor) continue;
      ensureLoaded(pollId, force: true);
    }
  }

  @override
  void onClose() {
    _fallbackTimer?.cancel();
    super.onClose();
  }

  /// Forces the next [ensureLoaded] per poll to refetch. Called when a chat
  /// opens, since votes may have changed while it was closed (no socket).
  void markAllStale() => _loaded.clear();

  /// Loads the poll + current user's vote (once until marked stale).
  Future<void> ensureLoaded(int pollId, {bool force = false}) async {
    if (pollId <= 0 || _loading.contains(pollId)) return;
    if (!force && _loaded.contains(pollId)) return;

    _loading.add(pollId);
    try {
      final res = await AttendanceRepo.getPoll(pollId);
      final data = res["data"];
      if (res["status"] == true && data is Map) {
        // A vote started while this was in flight: its response wins.
        if (_pendingMutations.contains(pollId)) return;
        _apply(data, hasMyVoteField: data.containsKey("myVote"));
        _loaded.add(pollId);
      }
    } catch (e) {
      log("ATTENDANCE GET POLL ERROR => $e");
    } finally {
      _loading.remove(pollId);
    }
  }

  /// Applies a server poll snapshot. Socket events (`fromEvent`) follow the
  /// version rule: anything not newer than the local copy is dropped.
  AttendancePoll? _apply(
    dynamic raw, {
    bool fromEvent = false,
    bool hasMyVoteField = false,
  }) {
    final incoming = AttendancePoll.fromJson(raw);
    if (incoming == null) return null;
    final local = polls[incoming.id];
    if (local == null) {
      // A count-only update for a poll we haven't loaded: fetch the full poll
      // instead of storing a card with no title/options.
      if (incoming.options.isEmpty) {
        ensureLoaded(incoming.id, force: true);
        return null;
      }
      polls[incoming.id] = incoming;
      return incoming;
    }
    // Only strictly older snapshots are dropped. An equal version is applied
    // (idempotent), so a backend that doesn't bump `version` on every vote
    // still updates counts live. version 0 = payload without a version.
    if (incoming.version > 0 && incoming.version < local.version) {
      debugPrint(
        "[RT_DEBUG] attendance poll=${incoming.id} dropped stale v${incoming.version} < v${local.version}",
      ); // TODO: remove debug log
      return local;
    }
    final merged = local.mergeServer(incoming, hasMyVoteField: hasMyVoteField);
    polls[incoming.id] = merged;
    if (fromEvent) {
      _lastLiveAt[incoming.id] = DateTime.now();
      _socketProven = true;
      debugPrint(
        "[RT_DEBUG] attendance poll=${incoming.id} applied v${merged.version} total=${merged.totalVotes} ${merged.countsByOption}",
      ); // TODO: remove debug log
    }
    return merged;
  }

  /// Socket events from the group room. Returns the chat message map for
  /// `attendance:created` so the chat can insert it.
  Map<String, dynamic>? handleSocketEvent(String event, dynamic data) {
    if (data is! Map) return null;
    final map = Map<String, dynamic>.from(data);
    switch (event) {
      case "attendance:created":
        _apply(map["poll"] ?? map["message"]?["attendance"]);
        return map["message"] is Map
            ? Map<String, dynamic>.from(map["message"])
            : null;
      case "attendance:updated":
        // Documented as {poll, version}; also accept a flat poll payload.
        final poll = map["poll"] is Map
            ? Map<String, dynamic>.from(map["poll"])
            : Map<String, dynamic>.from(map);
        if (map["version"] != null) poll["version"] = map["version"];
        poll["id"] ??= poll["pollId"] ?? map["pollId"];
        final applied = _apply(poll, fromEvent: true);
        // No counts in the event: refetch so the numbers still move live.
        if (applied != null && poll["counts"] is! Map) {
          ensureLoaded(applied.id, force: true);
        }
        break;
      case "attendance:edited":
        _apply(map["poll"], fromEvent: true);
        break;
      case "attendance:my_vote":
        final pollId = int.tryParse(map["pollId"]?.toString() ?? "");
        final local = pollId != null ? polls[pollId] : null;
        if (local != null) {
          final vote = AttendanceVote.fromJson(map["myVote"]);
          polls[pollId!] = local.copyWith(myVote: vote, clearMyVote: vote == null);
        } else if (pollId != null) {
          ensureLoaded(pollId, force: true);
        }
        break;
      case "attendance:closed":
        final pollId = int.tryParse(map["pollId"]?.toString() ?? "");
        final local = pollId != null ? polls[pollId] : null;
        if (local != null) {
          final version = int.tryParse(map["version"]?.toString() ?? "");
          final finalCounts = map["finalCounts"] is Map
              ? Map<String, dynamic>.from(map["finalCounts"])
              : null;
          final byOption = <String, int>{};
          if (finalCounts?["byOption"] is Map) {
            (finalCounts!["byOption"] as Map).forEach((k, v) {
              byOption[k.toString()] = int.tryParse(v.toString()) ?? 0;
            });
          }
          polls[pollId!] = local.copyWith(
            status: "closed",
            version: version != null && version > local.version ? version : null,
            totalVotes: int.tryParse(finalCounts?["total"]?.toString() ?? ""),
            countsByOption: byOption.isNotEmpty ? byOption : null,
          );
        }
        break;
      case "attendance:deleted":
        final pollId = int.tryParse(map["pollId"]?.toString() ?? "");
        if (pollId != null) polls.remove(pollId);
        break;
    }
    return null;
  }

  /// Reconnect recovery: refreshes the given polls in one socket round trip.
  void syncPolls(Iterable<int> pollIds) {
    final ids = pollIds.where((id) => id > 0).toSet().toList();
    _socket.syncAttendance(ids, (list) {
      for (final p in list) {
        _apply(p, fromEvent: true);
      }
    });
  }

  /// Creates a poll. Returns the API `data` ({pollId, messageId, message}).
  Future<Map<String, dynamic>> createPoll({
    required int groupId,
    required String title,
    String? description,
    required DateTime eventDate,
    required List<String> options,
    String? photoRequiredOptionLabel,
    bool allowVoteChange = true,
    DateTime? deadlineAt,
  }) async {
    final res = await AttendanceRepo.createPoll(
      groupId: groupId,
      title: title,
      description: description,
      eventDate: _isoDate(eventDate),
      options: [
        for (int i = 0; i < options.length; i++)
          {
            // Explicit unique IDs: the backend rejects the poll with
            // "Option IDs must be unique." when they are omitted.
            "id": "opt_${i + 1}",
            "label": options[i],
            "order": i + 1,
            ..._defaultOptionStyle(options[i]),
          },
      ],
      photoRequiredOptionLabel: photoRequiredOptionLabel,
      allowVoteChange: allowVoteChange,
      deadlineAt: deadlineAt,
    );

    if (res["status"] != true || res["data"] is! Map) {
      throw res["message"]?.toString() ?? "Unable to create attendance";
    }
    final data = Map<String, dynamic>.from(res["data"]);
    final message = data["message"];
    _apply(data["poll"] ??
        (message is Map ? message["attendance"] : null));
    return data;
  }

  /// Casts or changes the current user's vote. Counts update optimistically
  /// and roll back if the request fails.
  Future<void> vote({
    required int pollId,
    required String optionId,
    String? photoPath,
  }) async {
    _pendingMutations.add(pollId);
    final before = polls[pollId];
    if (before != null) {
      polls[pollId] = _withLocalVote(before, optionId, photoPath);
    }

    try {
      final fix = await prefetchLocation();

      final res = await AttendanceRepo.vote(
        pollId: pollId,
        optionId: optionId,
        clientRequestId: _requestId(),
        latitude: fix?.position.latitude,
        longitude: fix?.position.longitude,
        locationName: fix?.placeName,
        locationAccuracy: fix?.position.accuracy,
        photoPath: photoPath,
      );

      final data = res["data"];
      if (res["status"] != true || data is! Map) {
        throw res["message"]?.toString() ?? "Unable to record vote";
      }
      _applyMutationResult(pollId, Map<String, dynamic>.from(data), before);
    } catch (e) {
      _rollback(pollId, before);
      rethrow;
    } finally {
      _pendingMutations.remove(pollId);
    }
  }

  Future<void> removeVote(int pollId) async {
    _pendingMutations.add(pollId);
    final before = polls[pollId];
    if (before != null && before.myVote != null) {
      polls[pollId] = _withLocalVote(before, null, null);
    }
    try {
      final res = await AttendanceRepo.removeVote(pollId);
      final data = res["data"];
      if (res["status"] != true) {
        throw res["message"]?.toString() ?? "Unable to remove vote";
      }
      if (data is Map) {
        _applyMutationResult(
          pollId,
          {...Map<String, dynamic>.from(data), "myVote": null},
          before,
        );
      }
    } catch (e) {
      _rollback(pollId, before);
      rethrow;
    } finally {
      _pendingMutations.remove(pollId);
    }
  }

  Future<void> closePoll(int pollId) async {
    final res = await AttendanceRepo.closePoll(pollId);
    if (res["status"] != true) {
      throw res["message"]?.toString() ?? "Unable to close attendance";
    }
    final data = res["data"];
    if (data is Map && data["poll"] != null) {
      _apply(data["poll"]);
    } else if (polls[pollId] != null) {
      polls[pollId] = polls[pollId]!.copyWith(status: "closed");
    }
  }

  Future<void> deletePoll(int pollId) async {
    final res = await AttendanceRepo.deletePoll(pollId);
    if (res["status"] != true) {
      throw res["message"]?.toString() ?? "Unable to delete attendance";
    }
    polls.remove(pollId);
  }

  Future<AttendanceVotersPage> fetchVoters({
    required int pollId,
    String? optionId,
    bool notVoted = false,
    int page = 1,
    int limit = 50,
    String? search,
  }) async {
    final res = await AttendanceRepo.getVoters(
      pollId: pollId,
      optionId: optionId,
      notVoted: notVoted,
      page: page,
      limit: limit,
      search: search,
    );
    log("ATTENDANCE VOTERS RAW (poll=$pollId option=$optionId notVoted=$notVoted) => $res");
    if (res["status"] == false) {
      throw res["message"]?.toString() ?? "Unable to load voters";
    }
    final rawData = res["data"];
    // `data` is documented as {counts, voters, pagination}; also accept the
    // list directly or under another common key.
    final Map data = rawData is Map
        ? rawData
        : {"voters": rawData is List ? rawData : const []};

    final counts = data["counts"] is Map ? data["counts"] as Map : const {};
    final byOption = <String, int>{};
    if (counts["byOption"] is Map) {
      (counts["byOption"] as Map).forEach((k, v) {
        byOption[k.toString()] = int.tryParse(v.toString()) ?? 0;
      });
    }
    final rawVoters = const ["voters", "members", "items", "rows", "list", "results", "data"]
        .map((k) => data[k])
        .firstWhere((v) => v is List, orElse: () => const []) as List;
    final voters = rawVoters
        .whereType<Map>()
        .map((v) => AttendanceVoter.fromJson(Map<String, dynamic>.from(v)))
        .toList();
    final pagination =
        data["pagination"] is Map ? data["pagination"] as Map : const {};

    return AttendanceVotersPage(
      voters: voters,
      total: int.tryParse(counts["total"]?.toString() ?? "") ?? 0,
      countsByOption: byOption,
      notVoted: int.tryParse(counts["notVoted"]?.toString() ?? "") ?? 0,
      hasNext: pagination["hasNext"] == true,
    );
  }

  Future<String> exportCsv(int pollId) => AttendanceRepo.exportCsv(pollId);

  void _applyMutationResult(
    int pollId,
    Map<String, dynamic> data,
    AttendancePoll? before,
  ) {
    final poll = data["poll"];
    if (poll is Map) {
      // The vote response is authoritative, even at an equal version.
      final incoming = AttendancePoll.fromJson(poll);
      final local = polls[pollId] ?? before;
      if (incoming != null) {
        polls[pollId] = local == null
            ? incoming
            : local.mergeServer(incoming, hasMyVoteField: false);
      }
    }
    final current = polls[pollId];
    if (current != null && data.containsKey("myVote")) {
      final vote = AttendanceVote.fromJson(data["myVote"]);
      polls[pollId] = current.copyWith(myVote: vote, clearMyVote: vote == null);
    }
  }

  void _rollback(int pollId, AttendancePoll? before) {
    if (before != null) polls[pollId] = before;
    // Resync in case the server did apply part of the change.
    ensureLoaded(pollId, force: true);
  }

  AttendancePoll _withLocalVote(
    AttendancePoll poll,
    String? optionId,
    String? photoPath,
  ) {
    final counts = Map<String, int>.from(poll.countsByOption);
    final previous = poll.myVote?.optionId;
    var total = poll.totalVotes;
    if (previous != null) {
      counts[previous] = max(0, (counts[previous] ?? 0) - 1);
      total = max(0, total - 1);
    }
    if (optionId != null) {
      counts[optionId] = (counts[optionId] ?? 0) + 1;
      total += 1;
    }
    return poll.copyWith(
      countsByOption: counts,
      totalVotes: total,
      myVote: optionId != null
          ? AttendanceVote(
              optionId: optionId,
              votedAt: DateTime.now(),
              photoUrl: photoPath,
            )
          : null,
      clearMyVote: optionId == null,
    );
  }

  Map<String, String> _defaultOptionStyle(String label) {
    switch (label.trim().toLowerCase()) {
      case "present":
        return {"color": "#22C55E", "icon": "check_circle"};
      case "absent":
        return {"color": "#EF4444", "icon": "cancel"};
      default:
        return {};
    }
  }

  String _isoDate(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  /// Random v4-style UUID for vote idempotency.
  String _requestId() {
    final b = List<int>.generate(16, (_) => _random.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
    return "${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}";
  }

  Future<AttendanceLocationFix?>? _locationFuture;
  DateTime? _locationFetchedAt;

  /// Starts (or reuses, for 2 minutes) the GPS + place-name lookup. Called
  /// when a member picks an option so submitting doesn't wait on GPS.
  Future<AttendanceLocationFix?> prefetchLocation() {
    final fresh = _locationFetchedAt != null &&
        DateTime.now().difference(_locationFetchedAt!) <
            const Duration(minutes: 2);
    if (_locationFuture == null || !fresh) {
      _locationFetchedAt = DateTime.now();
      _locationFuture = () async {
        final position = await _currentPosition();
        if (position == null) {
          _locationFuture = null; // retry next time
          return null;
        }
        final name = await _placeName(position.latitude, position.longitude);
        return AttendanceLocationFix(position, name);
      }();
    }
    return _locationFuture!;
  }

  Future<Position?> _currentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 8));
    } catch (e) {
      log("ATTENDANCE LOCATION ERROR => $e");
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  Future<String?> _placeName(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng)
          .timeout(const Duration(seconds: 4));
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      final parts = [
        p.subLocality,
        p.locality,
        p.administrativeArea,
      ].where((e) => e != null && e.trim().isNotEmpty).toSet().toList();
      return parts.isEmpty ? null : parts.take(2).join(", ");
    } catch (e) {
      log("ATTENDANCE GEOCODE ERROR => $e");
      return null;
    }
  }
}
