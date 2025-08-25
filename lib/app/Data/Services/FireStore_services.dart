

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';

import 'package:uuid/uuid.dart';

import '../../Core/util/http/Constant.dart';
import '../../Model/call_model.dart';
import '../../modules/AgoraVideoandAudio_Call/agora_call_screen.dart';



class FireStoreServices {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// 🔔 Initialize notifications


  /// 📝 Save user device token
  Future<void> createUserDocument() async {
    try {
      String? deviceToken = await _messaging.getToken();
      await FirebaseFirestore.instance.collection('users').doc(Global.storageServices.get(Constant.userId).toString()).set({
        'device_token': deviceToken,
        'user_id': Global.storageServices.get(Constant.userId).toString(),
        'name': Global.storageServices.get(Constant.userId).toString(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('❌ Failed to create user doc: $e');
    }
  }

  /// ☎️ Start a call
  Future<void> startCall(BuildContext context, bool isVideo,
      {required int receiverId,}) async {
    final String? callerId = Global.storageServices.get(Constant.userId.toString());

    if (callerId == receiverId.toString()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot call yourself')),
      );
      return;
    }

    final channelId = const Uuid().v4();

    await FirebaseFirestore.instance.collection('calls').doc(channelId).set({
      'callerId': callerId,
      'receiverId': receiverId,
      'isVideo': isVideo,
      'status': 'calling',
      'callerName': Global.storageServices.get(Constant.userName.toString()),
      'callerProfileImage': Constant.ImagebaseUrl + Global.storageServices.get(Constant.profileImage.toString())!,
      'timestamp': FieldValue.serverTimestamp(),

    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgoraCallScreen(
          // channelId: channelId,
          // isVideo: isVideo,
          call: CallModel(callerId: callerId!, receiverId: receiverId.toString(), channelId: channelId, isVideo: isVideo, status: "calling", callerName: Global.storageServices.get(Constant.userName.toString())!, callerProfileImage: Constant.ImagebaseUrl + Global.storageServices.get(Constant.profileImage.toString())!,),
        ),
      ),
    );

    try {
      final receiverSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverId.toString())
          .get();

      if (!receiverSnapshot.exists) return;

      final receiverToken = receiverSnapshot['device_token'];

      await sendCallNotificationTerminated(
        receiverToken: receiverToken,
        callerId: callerId!,
        callerName:Global.storageServices.get(Constant.userName.toString())!,
        callerProfileImage: Constant.ImagebaseUrl + Global.storageServices.get(Constant.profileImage.toString())!,
        channelId: channelId,
        isVideo: isVideo,

      );
    } catch (e) {
      print('❌ Error fetching receiver token: $e');
    }
  }

  Future<void> sendCallNotificationTerminated({
    required String receiverToken,
    required String callerId,
    required String callerName,
    required String callerProfileImage,
    required String channelId,
    required bool isVideo,
  }) async {
    try {
      final jsonCredentials =
      await rootBundle.loadString('assets/service_account.json');
      final credentials = ServiceAccountCredentials.fromJson(jsonCredentials);
      final Map<String, dynamic> credentialsMap = json.decode(jsonCredentials);
      final String projectId = credentialsMap['project_id'];

      final client = await clientViaServiceAccount(
          credentials, ['https://www.googleapis.com/auth/firebase.messaging']);

      final message = {
        "message": {
          "token": receiverToken,
          "data": {
            "type": "call",
            "callerId": callerId,
            "callerName": callerName,
            "callerProfileImage": callerProfileImage,
            "channelId": channelId,
            "isVideo": isVideo.toString(),
            "custom_notification": "true" // flag to identify call notif
          },
          "android": {
            "priority": "high",
            "ttl": "60s" // time to live
          },
          "apns": {
            "payload": {
              "aps": {
                "content-available": 1
              }
            }
          }
        }
      };

      print("--------TerminatedCallPayload----------:$message");

      final response = await client.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(message),
      );

      if (response.statusCode == 200) {
        print('✅ Call notification (terminated) sent!');
      } else {
        print('❌ Failed: ${response.body}');
      }

      client.close();
    } catch (e) {
      print('❌ Error sending call notification: $e');
    }
  }



}

