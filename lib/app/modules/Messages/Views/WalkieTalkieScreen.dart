import 'package:flutter/material.dart';

import '../../../Data/Services/walkie_native_service.dart';


class WalkieTalkieScreen extends StatelessWidget {
  const WalkieTalkieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          // onTap: () async {
          //     print("StartTalking=============>");
          //     await WalkieNativeService.talk();
          // },
          onTapDown: (_) async {
            // 🎤 START TALKING
            print("StartTalking=============>");
            await WalkieNativeService.talk();
          },
          onTapUp: (_) async {
            // 🔇 STOP TALKING
            await WalkieNativeService.stop();
          },
          onTapCancel: () async {
            await WalkieNativeService.stop();
          },
          child: Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.greenAccent,
              boxShadow: [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.6),
                  blurRadius: 30,
                ),
              ],
            ),
            child: const Icon(
              Icons.mic,
              size: 70,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
