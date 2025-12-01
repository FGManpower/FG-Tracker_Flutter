import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

import '../controller/call_controller.dart';


class CallScreen extends StatelessWidget {
  final controller = Get.put(CallController());

  CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CallController>(
      builder: (c) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(title: const Text("P2P Call App")),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      RTCVideoView(
                        c.remoteRenderer,
                        objectFit:
                        RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
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
                      ),
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
                            c.isAudioOn ? Icons.mic : Icons.mic_off),
                        onPressed: c.toggleMic,
                      ),
                      IconButton(
                        icon: const Icon(Icons.call_end),
                        iconSize: 30,
                        onPressed: c.endCall,
                      ),
                      IconButton(
                        icon: const Icon(Icons.cameraswitch),
                        onPressed: c.switchCamera,
                      ),
                      IconButton(
                        icon: Icon(
                            c.isVideoOn ? Icons.videocam : Icons.videocam_off),
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
