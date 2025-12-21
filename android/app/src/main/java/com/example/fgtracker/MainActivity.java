package com.example.fgtracker;

import android.content.Intent;
import android.os.Build;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "walkie_native";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                CHANNEL
        ).setMethodCallHandler((call, result) -> {

            Intent intent = new Intent(this, WalkieService.class);

            switch (call.method) {

                case "startService": {
                    System.out.println("🚀 startService called from Flutter");
                    String myUserId = (String) call.argument("myUserId");
                    String remoteUserId = (String) call.argument("remoteUserId");

                    intent.setAction(WalkieService.ACTION_START);
                    intent.putExtra("myUserId", myUserId);
                    intent.putExtra("remoteUserId", remoteUserId);

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent);
                    } else {
                        startService(intent);
                    }

                    result.success(null);
                    break;
                }

                case "startTalking":
                    System.out.println("🎤 startTalking intent sent to service");
                    intent.setAction(WalkieService.ACTION_TALK_START);
                    startService(intent);
                    result.success(null);
                    break;

                case "stopTalking":
                    intent.setAction(WalkieService.ACTION_TALK_STOP);
                    startService(intent);
                    result.success(null);
                    break;

                case "saveUserId": {
                    String userId = call.argument("userId");
                    UserSession.saveUserId(this, userId);
                    result.success(null);
                    break;
                }




                default:
                    result.notImplemented();
            }
        });
    }
}
