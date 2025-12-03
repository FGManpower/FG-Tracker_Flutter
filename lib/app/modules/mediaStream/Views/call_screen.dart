import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../controller/call_controller.dart';

class CallScreen extends StatelessWidget {
  final controller = Get.put(CallController());

  CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CallController>(
      builder: (c) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      c.is_video == true
                          ? RTCVideoView(
                              c.remoteRenderer,
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitCover,
                            )
                          : Center(
                              child: Icon(
                                Icons.call,
                                size: 140,
                                color: Colors.greenAccent,
                              ),
                            ),
                      if (c.is_video == true)
                        Positioned(
                          right: 20,
                          bottom: 20,
                          child: SizedBox(
                            height: 150,
                            width: 120,
                            child: RTCVideoView(
                              c.localRenderer,
                              mirror: c.isFrontCamera,
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitCover,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(
                          c.isAudioOn ? Icons.mic : Icons.mic_off,
                          color: Colors.white,
                        ),
                        onPressed: c.toggleMic,
                      ),
                      IconButton(
                        icon: const Icon(Icons.call_end, color: Colors.red),
                        iconSize: 40,
                        onPressed: c.endCall,
                      ),
                      if (c.is_video == true)
                        IconButton(
                          icon: const Icon(Icons.cameraswitch,
                              color: Colors.white),
                          onPressed: c.switchCamera,
                        ),
                      if (c.is_video == true)
                        IconButton(
                          icon: Icon(
                            c.isVideoOn ? Icons.videocam : Icons.videocam_off,
                            color: Colors.white,
                          ),
                          onPressed: c.toggleCamera,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
