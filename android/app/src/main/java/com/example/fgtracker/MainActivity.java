package com.example.fgtracker;

import android.app.PictureInPictureParams;
import android.content.ContentResolver;
import android.content.Intent;
import android.content.res.Configuration;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.OpenableColumns;
import android.util.Rational;
import android.webkit.MimeTypeMap;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

/**
 * Picture-in-picture for 1:1 video calls (calling doc 02, BUG-CALL-16)
 * + OS Share Sheet intake (ACTION_SEND / ACTION_SEND_MULTIPLE).
 */
public class MainActivity extends FlutterActivity {
    private static final String PIP_CHANNEL = "com.fgtracker/pip";
    private static final String SHARE_CHANNEL = "com.fgtracker/share_intake";
    private static final String SHARE_EVENTS = "com.fgtracker/share_intake_events";
    private static final String EXTRA_SHARE_HANDLED = "com.fgtracker.extra.SHARE_HANDLED";

    private MethodChannel pipChannel;
    private EventChannel.EventSink shareEventSink;
    private Map<String, Object> pendingSharePayload;
    private MethodChannel.Result pendingInitialShareResult;
    private boolean isProcessingShareIntent = false;
    private final ExecutorService shareExecutor = Executors.newSingleThreadExecutor();

    private boolean autoPip = false;
    private int aspectW = 9;
    private int aspectH = 16;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        handleShareIntent(getIntent());
    }

    @Override
    protected void onNewIntent(@NonNull Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        handleShareIntent(intent);
    }

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

        MethodChannel restartChannel = new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(), "app.restart.channel");
        restartChannel.setMethodCallHandler((call, result) -> {
            if ("restartApp".equals(call.method)) {
                try {
                    Intent intent = getPackageManager().getLaunchIntentForPackage(getPackageName());
                    if (intent != null) {
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                        startActivity(intent);
                        Runtime.getRuntime().exit(0);
                    }
                    result.success(null);
                } catch (Exception e) {
                    result.error("RESTART_FAILED", e.getMessage(), null);
                }
            } else {
                result.notImplemented();
            }
        });

        MethodChannel shareChannel = new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(), SHARE_CHANNEL);
        shareChannel.setMethodCallHandler((call, result) -> {
            if ("getInitialSharedPayload".equals(call.method)) {
                if (pendingSharePayload != null) {
                    Map<String, Object> payload = pendingSharePayload;
                    pendingSharePayload = null;
                    result.success(payload);
                } else if (isProcessingShareIntent) {
                    pendingInitialShareResult = result;
                } else {
                    result.success(null);
                }
            } else {
                result.notImplemented();
            }
        });

        EventChannel shareEvents = new EventChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(), SHARE_EVENTS);
        shareEvents.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                shareEventSink = events;
                if (pendingSharePayload != null) {
                    Map<String, Object> payload = pendingSharePayload;
                    pendingSharePayload = null;
                    events.success(payload);
                }
            }

            @Override
            public void onCancel(Object arguments) {
                shareEventSink = null;
            }
        });
    }

    private void handleShareIntent(@Nullable Intent intent) {
        if (intent == null) return;
        String action = intent.getAction();
        if (!Intent.ACTION_SEND.equals(action) && !Intent.ACTION_SEND_MULTIPLE.equals(action)) {
            return;
        }
        if (intent.getBooleanExtra(EXTRA_SHARE_HANDLED, false)) {
            return;
        }
        intent.putExtra(EXTRA_SHARE_HANDLED, true);

        final String intentType = intent.getType();
        final String sharedText = intent.getStringExtra(Intent.EXTRA_TEXT);
        final String sharedSubject = intent.getStringExtra(Intent.EXTRA_SUBJECT);
        final List<Uri> streamUris = new ArrayList<>();

        if (Intent.ACTION_SEND.equals(action)) {
            Uri uri = getParcelableUri(intent, Intent.EXTRA_STREAM);
            if (uri != null) {
                streamUris.add(uri);
            }
        } else {
            ArrayList<Uri> uris = getParcelableUriList(intent, Intent.EXTRA_STREAM);
            if (uris != null) {
                for (Uri uri : uris) {
                    if (uri != null) streamUris.add(uri);
                }
            }
        }

        isProcessingShareIntent = true;
        shareExecutor.execute(() -> {
            Map<String, Object> payload = buildSharePayload(
                    intentType,
                    sharedText,
                    sharedSubject,
                    streamUris
            );
            runOnUiThread(() -> {
                isProcessingShareIntent = false;
                if (pendingInitialShareResult != null) {
                    MethodChannel.Result res = pendingInitialShareResult;
                    pendingInitialShareResult = null;
                    res.success(payload);
                } else if (shareEventSink != null) {
                    shareEventSink.success(payload);
                } else {
                    pendingSharePayload = payload;
                }
            });
        });
    }

    @SuppressWarnings("deprecation")
    @Nullable
    private Uri getParcelableUri(Intent intent, String key) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            return intent.getParcelableExtra(key, Uri.class);
        }
        return intent.getParcelableExtra(key);
    }

    @SuppressWarnings("deprecation")
    @Nullable
    private ArrayList<Uri> getParcelableUriList(Intent intent, String key) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            return intent.getParcelableArrayListExtra(key, Uri.class);
        }
        return intent.getParcelableArrayListExtra(key);
    }

    private Map<String, Object> buildSharePayload(
            @Nullable String intentType,
            @Nullable String sharedText,
            @Nullable String sharedSubject,
            List<Uri> streamUris
    ) {
        Map<String, Object> map = new HashMap<>();
        map.put("source", "external");
        map.put("createdAtMs", System.currentTimeMillis());

        String effectiveText = sharedText != null ? sharedText.trim() : "";
        if (effectiveText.isEmpty() && sharedSubject != null) {
            effectiveText = sharedSubject.trim();
        }
        if (!effectiveText.isEmpty()) {
            map.put("text", effectiveText);
        }

        List<Map<String, Object>> copiedFiles = new ArrayList<>();
        String firstMime = intentType;
        boolean permissionDenied = false;
        boolean readFailed = false;

        for (Uri uri : streamUris) {
            try {
                Map<String, Object> fileInfo = copyUriToCache(uri, intentType);
                if (fileInfo != null) {
                    copiedFiles.add(fileInfo);
                    if (firstMime == null || "*/*".equals(firstMime)) {
                        Object mimeObj = fileInfo.get("mimeType");
                        if (mimeObj instanceof String) {
                            firstMime = (String) mimeObj;
                        }
                    }
                } else {
                    readFailed = true;
                }
            } catch (SecurityException se) {
                permissionDenied = true;
            } catch (Exception e) {
                readFailed = true;
            }
        }

        if (copiedFiles.isEmpty() && !streamUris.isEmpty()) {
            if (permissionDenied) {
                map.put("error", "permission_denied");
            } else if (readFailed) {
                map.put("error", "read_failed");
            }
        }

        map.put("files", copiedFiles);
        map.put("kind", resolveKind(copiedFiles, firstMime, effectiveText));
        return map;
    }

    @Nullable
    private Map<String, Object> copyUriToCache(Uri uri, @Nullable String fallbackMime) throws Exception {
        ContentResolver resolver = getContentResolver();
        String mime = resolver.getType(uri);
        if (mime == null || mime.trim().isEmpty()) {
            mime = fallbackMime;
        }

        String displayName = queryDisplayName(resolver, uri);
        if (displayName == null || displayName.trim().isEmpty()) {
            String ext = mime != null ? MimeTypeMap.getSingleton().getExtensionFromMimeType(mime) : null;
            displayName = "shared_" + System.currentTimeMillis() + (ext != null ? "." + ext : "");
        }
        displayName = displayName.replaceAll("[^a-zA-Z0-9._-]", "_");

        File shareDir = new File(getCacheDir(), "share_intake");
        if (!shareDir.exists()) {
            //noinspection ResultOfMethodCallIgnored
            shareDir.mkdirs();
        }

        File outFile = new File(shareDir, System.currentTimeMillis() + "_" + displayName);
        try (InputStream in = resolver.openInputStream(uri);
             FileOutputStream out = new FileOutputStream(outFile)) {
            if (in == null) return null;
            byte[] buffer = new byte[16 * 1024];
            int len;
            while ((len = in.read(buffer)) != -1) {
                out.write(buffer, 0, len);
            }
            out.flush();
        }

        Map<String, Object> item = new HashMap<>();
        item.put("path", outFile.getAbsolutePath());
        item.put("name", displayName);
        if (mime != null) item.put("mimeType", mime);
        item.put("sizeBytes", outFile.length());
        return item;
    }

    @Nullable
    private String queryDisplayName(ContentResolver resolver, Uri uri) {
        if ("file".equalsIgnoreCase(uri.getScheme())) {
            String path = uri.getPath();
            if (path != null) {
                return new File(path).getName();
            }
        }
        try (Cursor cursor = resolver.query(uri, new String[]{OpenableColumns.DISPLAY_NAME}, null, null, null)) {
            if (cursor != null && cursor.moveToFirst()) {
                int idx = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
                if (idx >= 0) return cursor.getString(idx);
            }
        } catch (Exception ignored) {
        }
        return uri.getLastPathSegment();
    }

    private String resolveKind(List<Map<String, Object>> files, @Nullable String mime, String text) {
        if (!files.isEmpty()) {
            String effectiveMime = mime != null ? mime.toLowerCase() : "";
            if (effectiveMime.startsWith("image/")) return "image";
            if (effectiveMime.startsWith("video/")) return "video";
            if (effectiveMime.startsWith("audio/")) return "audio";
            return "file";
        }
        if ((text.startsWith("http://") || text.startsWith("https://")) && !text.contains(" ")) {
            return "link";
        }
        return "text";
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
    // (protected here fails to compile: "weaker access privileges").
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

    @Override
    protected void onDestroy() {
        shareExecutor.shutdownNow();
        super.onDestroy();
    }
}
