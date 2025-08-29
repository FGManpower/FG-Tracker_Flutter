// lib/screens/incoming_call_screen.dart
import 'package:flutter/material.dart';

class IncomingCallScreen extends StatelessWidget {
  final Map callData;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const IncomingCallScreen({
    super.key,
    required this.callData,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final caller = callData['caller_name'] ?? callData['from'] ?? 'Unknown';
    final isVideo = callData['is_video'] == true || callData['is_video'] == 'true';
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 56, child: Icon(Icons.person, size: 56)),
            const SizedBox(height: 20),
            Text(caller, style: const TextStyle(color: Colors.white, fontSize: 24)),
            const SizedBox(height: 6),
            Text(isVideo ? 'Video Call' : 'Audio Call', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'reject',
                  onPressed: onReject,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.call_end),
                ),
                FloatingActionButton(
                  heroTag: 'accept',
                  onPressed: onAccept,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.call),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
