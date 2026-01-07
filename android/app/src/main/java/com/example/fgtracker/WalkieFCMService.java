package com.example.fgtracker;

import android.content.Intent;
import android.os.Build;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

public class WalkieFCMService extends FirebaseMessagingService {

    @Override
    public void onMessageReceived(RemoteMessage message) {
        System.out.println("🔥 WalkieFCMService triggered");
        if (message.getData() == null) return;

        String type = message.getData().get("type");
        if (!"WALKIE_CALL".equals(type)) return;

        String fromUserId = message.getData().get("fromUserId");
        String myUserId = UserSession.getUserId(this);

        if (myUserId == null) {
            System.out.println("❌ myUserId is NULL, cannot start WalkieService");
            return;
        }

        System.out.println("📲 WALKIE_CALL received → from " + fromUserId);

        Intent intent = new Intent(this, WalkieService.class);
        intent.setAction(WalkieService.ACTION_START);
        intent.putExtra("myUserId", myUserId);
        intent.putExtra("remoteUserId", fromUserId);
        intent.putExtra("isCaller", false);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent);
        } else {
            startService(intent);
        }
    }
}
