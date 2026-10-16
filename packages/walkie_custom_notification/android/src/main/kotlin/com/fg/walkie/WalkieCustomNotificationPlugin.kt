package com.fg.walkie

import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.PorterDuffXfermode
import android.graphics.Rect
import android.graphics.RectF
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.Executors

class WalkieCustomNotificationPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.NewIntentListener {
    companion object {
        const val CHANNEL_ID = "fg_tracker_walkie_heads_up_channel_v6"
        const val CHANNEL_NAME = "Walkie-Talkie Active Channels"
        const val NOTIFICATION_ID = 90210
        const val ACTION_ACCEPT = "com.fg.walkie.ACTION_ACCEPT"
        const val ACTION_REJECT = "com.fg.walkie.ACTION_REJECT"

        private val executor = Executors.newSingleThreadExecutor()

        fun showNotification(
            ctx: Context,
            speakerName: String,
            groupName: String,
            groupId: String,
            speakerImage: String,
            joinedCount: Int? = null
        ) {
            val nm = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager ?: return

            // Cancel any previous notifications (including default FCM ones)
            try {
                nm.cancelAll()
            } catch (_: Exception) {}

            val soundResId = ctx.resources.getIdentifier("walkie_talkie_ringtone", "raw", ctx.packageName).let {
                if (it != 0) it else ctx.resources.getIdentifier("recieve_notification", "raw", ctx.packageName)
            }
            val soundUri: Uri = if (soundResId != 0) {
                Uri.parse("android.resource://${ctx.packageName}/$soundResId")
            } else {
                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                // Delete older channels to ensure cached settings don't suppress Heads-Up
                try {
                    nm.deleteNotificationChannel("fg_tracker_walkie_custom_channel_v1")
                    nm.deleteNotificationChannel("fg_tracker_walkie_custom_channel_v2")
                    nm.deleteNotificationChannel("fg_tracker_walkie_heads_up_channel_v4")
                    nm.deleteNotificationChannel("fg_tracker_walkie_heads_up_channel_v5")
                } catch (_: Exception) {}

                val audioAttr = AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                    .build()

                var nChannel = nm.getNotificationChannel(CHANNEL_ID)
                if (nChannel == null || nChannel.importance < NotificationManager.IMPORTANCE_HIGH) {
                    if (nChannel != null) {
                        try {
                            nm.deleteNotificationChannel(CHANNEL_ID)
                        } catch (_: Exception) {}
                    }
                    nChannel = NotificationChannel(
                        CHANNEL_ID,
                        CHANNEL_NAME,
                        NotificationManager.IMPORTANCE_HIGH
                    ).apply {
                        description = "Walkie Talkie Active Speaker Notifications"
                        enableVibration(true)
                        vibrationPattern = longArrayOf(0, 250, 250, 250)
                        lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
                        setSound(soundUri, audioAttr)
                    }
                    nm.createNotificationChannel(nChannel)
                }
            }

            // PendingIntent for ACCEPT action (Direct Activity launch to prevent trampoline block on Android 12+)
            val acceptIntent = ctx.packageManager.getLaunchIntentForPackage(ctx.packageName)?.apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
                putExtra("walkie_action", "accept")
                putExtra("speaker_name", speakerName)
                putExtra("group_name", groupName)
                putExtra("group_id", groupId)
            }
            val acceptPendingIntent = PendingIntent.getActivity(
                ctx,
                101,
                acceptIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // PendingIntent for REJECT/CANCEL action
            val rejectIntent = Intent(ctx, WalkieActionReceiver::class.java).apply {
                action = ACTION_REJECT
                putExtra("speaker_name", speakerName)
                putExtra("group_name", groupName)
                putExtra("group_id", groupId)
            }
            val rejectPendingIntent = PendingIntent.getBroadcast(
                ctx,
                102,
                rejectIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Content PendingIntent if user taps card body
            val contentIntent = ctx.packageManager.getLaunchIntentForPackage(ctx.packageName)?.apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
                putExtra("walkie_action", "open")
                putExtra("speaker_name", speakerName)
                putExtra("group_name", groupName)
                putExtra("group_id", groupId)
            }
            val contentPendingIntent = PendingIntent.getActivity(
                ctx,
                103,
                contentIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val displayGroupName = if (groupName.trim().isNotEmpty()) groupName.trim() else "Field Team"
            val displaySpeakerText = if (speakerName.trim().isNotEmpty()) {
                "${speakerName.trim()} is speaking..."
            } else {
                "Someone is speaking..."
            }
            val countText = if (joinedCount != null && joinedCount > 0) {
                "👥 $joinedCount Joined"
            } else {
                "👥 Active"
            }

            // Expanded RemoteViews
            val expandedViews = RemoteViews(ctx.packageName, R.layout.custom_walkie_notification_expanded).apply {
                setTextViewText(R.id.notification_group_name, displayGroupName)
                setTextViewText(R.id.notification_speaker_subtext, displaySpeakerText)
                setTextViewText(R.id.notification_joined_count, countText)

                setOnClickPendingIntent(R.id.btn_accept, acceptPendingIntent)
                setOnClickPendingIntent(R.id.btn_cancel, rejectPendingIntent)
            }

            // Collapsed RemoteViews
            val collapsedViews = RemoteViews(ctx.packageName, R.layout.custom_walkie_notification_collapsed).apply {
                setTextViewText(R.id.notification_group_name, displayGroupName)
                setTextViewText(R.id.notification_speaker_subtext, displaySpeakerText)

                setOnClickPendingIntent(R.id.btn_accept, acceptPendingIntent)
                setOnClickPendingIntent(R.id.btn_cancel, rejectPendingIntent)
            }

            val smallIconRes = ctx.resources.getIdentifier("ic_launcher", "mipmap", ctx.packageName).let {
                if (it != 0) it else android.R.drawable.ic_dialog_info
            }

            val fullScreenIntent = WalkieIncomingActivity.createIntent(
                ctx, speakerName, groupName, groupId, speakerImage, joinedCount
            )
            val fullScreenPendingIntent = PendingIntent.getActivity(
                ctx,
                104,
                fullScreenIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val builder = NotificationCompat.Builder(ctx, CHANNEL_ID)
                .setSmallIcon(smallIconRes)
                .setCustomContentView(collapsedViews)
                .setCustomBigContentView(expandedViews)
                .setCustomHeadsUpContentView(collapsedViews)
                .setContentIntent(contentPendingIntent)
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setCategory(NotificationCompat.CATEGORY_CALL)
                .setSound(soundUri)
                .setVibrate(longArrayOf(0, 250, 250, 250))
                .setDefaults(NotificationCompat.DEFAULT_LIGHTS or NotificationCompat.DEFAULT_VIBRATE)
                .setOngoing(false)

            // On Android 14+ (API 34+), fullScreenIntent is rejected and suppresses Heads-Up if permission is not granted
            val canUseFsi = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                nm.canUseFullScreenIntent()
            } else {
                true
            }
            if (canUseFsi) {
                builder.setFullScreenIntent(fullScreenPendingIntent, true)
            }

            // Briefly wake up screen if interactive is false (screen is off/locked)
            try {
                val pm = ctx.getSystemService(Context.POWER_SERVICE) as? PowerManager
                if (pm != null && !pm.isInteractive) {
                    @Suppress("DEPRECATION")
                    val wl = pm.newWakeLock(
                        PowerManager.FULL_WAKE_LOCK or
                        PowerManager.ACQUIRE_CAUSES_WAKEUP or
                        PowerManager.ON_AFTER_RELEASE,
                        "fgtracker:walkie_notif_wake"
                    )
                    wl.acquire(3000)
                }
            } catch (_: Exception) {}

            // Post notification
            nm.notify(NOTIFICATION_ID, builder.build())
        }
    }

    private var context: Context? = null
    private var channel: MethodChannel? = null
    private var currentActivity: Activity? = null
    private var activityBinding: ActivityPluginBinding? = null
    private var pendingActionData: Map<String, Any?>? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "com.fg.walkie/notification")
        channel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        context = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        currentActivity = binding.activity
        binding.addOnNewIntentListener(this)
        handleIntent(binding.activity.intent)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        currentActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityBinding = binding
        currentActivity = binding.activity
        binding.addOnNewIntentListener(this)
    }

    override fun onDetachedFromActivity() {
        activityBinding?.removeOnNewIntentListener(this)
        activityBinding = null
        currentActivity = null
    }

    override fun onNewIntent(intent: Intent): Boolean {
        handleIntent(intent)
        return false
    }

    private fun handleIntent(intent: Intent?) {
        if (intent == null) return
        val action = intent.getStringExtra("walkie_action")
        if (!action.isNullOrEmpty()) {
            val ctx = context
            if (ctx != null) {
                val nm = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
                nm?.cancel(NOTIFICATION_ID)
            }
            val data = mapOf(
                "action" to action,
                "groupId" to (intent.getStringExtra("group_id") ?: ""),
                "groupName" to (intent.getStringExtra("group_name") ?: ""),
                "speakerName" to (intent.getStringExtra("speaker_name") ?: "")
            )
            pendingActionData = data
            channel?.invokeMethod("onWalkieAction", data)
            intent.removeExtra("walkie_action")
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "showNotification" -> {
                val speakerName = call.argument<String>("speakerName") ?: "Someone"
                val groupName = call.argument<String>("groupName") ?: ""
                val groupId = call.argument<String>("groupId") ?: ""
                val speakerImage = call.argument<String>("speakerImage") ?: ""
                val joinedCount = call.argument<Int?>("joinedCount")

                val ctx = context
                if (ctx == null) {
                    result.error("NO_CONTEXT", "Plugin context is null", null)
                    return
                }

                showNotification(ctx, speakerName, groupName, groupId, speakerImage, joinedCount)
                result.success(true)
            }
            "cancelNotification" -> {
                val ctx = context
                if (ctx != null) {
                    val nm = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
                    nm?.cancel(NOTIFICATION_ID)
                }
                result.success(true)
            }
            "getInitialAction" -> {
                val data = pendingActionData
                pendingActionData = null
                result.success(data)
            }
            else -> result.notImplemented()
        }
    }
}
