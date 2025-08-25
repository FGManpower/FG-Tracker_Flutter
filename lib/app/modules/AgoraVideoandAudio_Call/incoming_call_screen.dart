import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fgtracker/app/Core/deep_Link/uniservices.dart';
import 'package:fgtracker/app/Core/util/http/Constant.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:permission_handler/permission_handler.dart';

import '../../Data/Services/CallStateTracker.dart';
import '../../Model/call_model.dart';

import 'agora_call_screen.dart';

class IncomingCallScreen extends StatefulWidget {
  final CallModel call;

  const IncomingCallScreen({Key? key, required this.call}) : super(key: key);

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  Future<void> _acceptCall(BuildContext context) async {
    try {
      _stopRingtone();

      await FirebaseFirestore.instance
          .collection("calls")
          .doc(widget.call.channelId)
          .update({'status': 'accepted'});

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AgoraCallScreen(
            call: widget.call,
          ),
        ),
      );
      // } else {
      //   CommonDialog.ConfirmationDialog(
      //     title: "Camera & Microphone Permission Required",
      //     content:
      //         "To continue with the call, we need access to your camera and microphone. "
      //         "Please enable the permissions from the settings to proceed.",
      //     onConfirm: () {
      //       Navigator.pop(context);
      //       openAppSettings();
      //     },
      //   );
      // }
    } catch (e) {
      print("❌ Error accepting call: $e");
    }
  }

  Future<void> _rejectCall(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('calls')
          .doc(widget.call.channelId)
          .set({'hasEnded': true});

      CallStateTracker.isIncomingCallScreenOpen = false;

      _stopRingtone();
      Global.storageServices.remove(Constant.incomingCall);
      Navigator.pop(context, "true");
    } catch (e) {
      print("❌ Error rejecting call: $e");
    }
  }

  StreamSubscription<DocumentSnapshot>? _callStreamSubscription;
  bool isRingtonePlaying = false;

  void _playRingtone() {
    if (!isRingtonePlaying) {
      FlutterRingtonePlayer().play(
        asAlarm: true,
        fromAsset: "assets/music/Incoming_Call.mp3",
        looping: true,
        volume: 1.0,
      );
      isRingtonePlaying = true;
    }
  }

  void _stopRingtone() {
    if (isRingtonePlaying) {
      FlutterRingtonePlayer().stop();
      isRingtonePlaying = false;
    }
  }

  @override
  void initState() {
    super.initState();
    AppLinkStateTracker.isIncomingScreenOpened = true;

    _playRingtone();

    CallStateTracker.isIncomingCallScreenOpen = true;

    _callStreamSubscription = FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.call.channelId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data()?['hasEnded'] == true ||
          snapshot.data()?['status'] == 'rejected') {
        _stopRingtone();
        CallStateTracker.isIncomingCallScreenOpen = false;

        Get.back();
      }
    });
  }

  @override
  void dispose() {
    CallStateTracker.isIncomingCallScreenOpen = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          // return false;
        },
        child: Scaffold(
          backgroundColor: Colors.black87,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.grey.shade900,
                  Colors.black38,
                  Colors.grey.shade900,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.only(top: 40),
                    child: reausabletext(
                      widget.call.isVideo
                          ? "Incoming Video Call"
                          : "Incoming Audio Call",
                      color: Colors.white,
                      fontsize: 26,
                      fontweight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 50),
                  const Spacer(),

                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        NetworkImage(widget.call.callerProfileImage),
                    backgroundColor: Colors.grey[300],
                  ),
                  SizedBox(height: 20),

                  Text(
                    widget.call.callerName ?? "Unknown",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Removed Channel ID to simplify UI
                  const SizedBox(height: 30),
                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Padding(
                      padding: EdgeInsetsGeometry.only(left: 50, right: 50),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => _rejectCall(context),
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(60),
                                      ),
                                      child: Icon(
                                        Icons.alarm,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                    reausabletext('Remind me',
                                        color: Colors.grey.shade400,
                                        fontsize: 14)
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _rejectCall(context),
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(60),
                                      ),
                                      // padding:  EdgeInsets.all(20),
                                      child: Icon(
                                        Icons.message,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                    reausabletext('Message',
                                        color: Colors.grey.shade400,
                                        fontsize: 14)
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => _rejectCall(context),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(40),
                                    boxShadow: [
                                      // BoxShadow(
                                      //   color: Colors.redAccent.withOpacity(0.3),
                                      //   blurRadius: 15,
                                      //   spreadRadius: 2,
                                      // ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  child: const Icon(
                                    Icons.call_end,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _acceptCall(context),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(40),
                                    boxShadow: [],
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  child: const Icon(
                                    Icons.call,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ));
  }
}
