package com.fg.walkie

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class WalkieActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action

        if (action == "com.fg.walkie.TEST_NOTIFICATION") {
            val speaker = intent.getStringExtra("speaker") ?: "Jack Lala"
            val group = intent.getStringExtra("group") ?: "Field Team"
            WalkieCustomNotificationPlugin.showNotification(
                context,
                speaker,
                group,
                "21",
                "",
                2
            )
            return
        }

        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager

        // Cancel all walkie notifications immediately
        try {
            notificationManager?.cancel(WalkieCustomNotificationPlugin.NOTIFICATION_ID)
            notificationManager?.cancelAll()
        } catch (_: Exception) {}

        if (action == WalkieCustomNotificationPlugin.ACTION_ACCEPT) {
            val groupId = intent.getStringExtra("group_id") ?: ""
            val groupName = intent.getStringExtra("group_name") ?: ""
            val speakerName = intent.getStringExtra("speaker_name") ?: ""

            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
                putExtra("walkie_action", "accept")
                putExtra("group_id", groupId)
                putExtra("group_name", groupName)
                putExtra("speaker_name", speakerName)
            }
            if (launchIntent != null) {
                context.startActivity(launchIntent)
            }
        }

        // Close system notification shade if allowed
        try {
            @Suppress("DEPRECATION")
            context.sendBroadcast(Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS))
        } catch (_: Exception) {}
    }
}
