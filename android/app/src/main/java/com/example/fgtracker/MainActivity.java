package com.example.fgtracker;

import android.app.PictureInPictureParams;
import android.content.res.Configuration;
import android.os.Build;
import android.util.Rational;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

/**
 * Picture-in-picture for 1:1 video calls (calling doc 02, BUG-CALL-16).
 *
 * Dart (lib/app/modules/mediaStream/Services/call_pip.dart) turns "auto PiP"
 * on only while a connected video call screen is open. Leaving the app then
 * shows the call in a floating window. Nothing changes for any other screen.
 */
public class MainActivity extends FlutterActivity {
    private static final String PIP_CHANNEL = "com.fgtracker/pip";

    private MethodChannel pipChannel;
    private boolean autoPip = false;
    private int aspectW = 9;
    private int aspectH = 16;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        pipChannel = new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(), PIP_CHANNEL);
        pipChannel.setMethodCallHandler((call, result) -> {
            switch (call.method) {
                case "setAutoPip": {
                    Boolean enabled = call.argument("enabled");
                    Integer w = call.argument("width");
                    Integer h = call.argument("height");
                    autoPip = enabled != null && enabled;
                    if (w != null && h != null && w > 0 && h > 0) {
                        aspectW = w;
                        aspectH = h;
                    }
                    applyPipParams();
                    result.success(null);
                    break;
                }
                case "enterPip":
                    result.success(enterPip());
                    break;
                case "isSupported":
                    result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O);
                    break;
                default:
                    result.notImplemented();
            }
        });
    }

    private PictureInPictureParams buildParams() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return null;
        PictureInPictureParams.Builder b = new PictureInPictureParams.Builder()
                .setAspectRatio(new Rational(aspectW, aspectH));
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            b.setAutoEnterEnabled(autoPip);
            b.setSeamlessResizeEnabled(true);
        }
        return b.build();
    }

    private void applyPipParams() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return;
        try {
            setPictureInPictureParams(buildParams());
        } catch (Exception ignored) {
            // PiP not allowed on this device: the call continues normally.
        }
    }

    private boolean enterPip() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false;
        try {
            return enterPictureInPictureMode(buildParams());
        } catch (Exception e) {
            return false;
        }
    }

    // public: newer Flutter declares FlutterActivity.onUserLeaveHint() public
    // (protected here failed to compile: "weaker access privileges").
    // public also compiles against older Flutter, where it was protected.
    @Override
    public void onUserLeaveHint() {
        super.onUserLeaveHint();
        // Android 12+ enters PiP by itself (setAutoEnterEnabled).
        if (autoPip
                && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
                && Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            enterPip();
        }
    }

    @Override
    public void onPictureInPictureModeChanged(boolean isInPictureInPictureMode,
                                              Configuration newConfig) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig);
        if (pipChannel != null) {
            pipChannel.invokeMethod("onPipChanged", isInPictureInPictureMode);
        }
    }
}
