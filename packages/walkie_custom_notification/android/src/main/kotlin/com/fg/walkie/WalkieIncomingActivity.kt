package com.fg.walkie

import android.app.Activity
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.WindowManager
import android.widget.TextView

class WalkieIncomingActivity : Activity() {

    companion object {
        private const val TAG = "WalkieIncomingActivity"
        private const val AUTO_DISMISS_DELAY_MS = 25000L // 25 seconds

        fun createIntent(
            context: Context,
            speakerName: String,
            groupName: String,
            groupId: String,
            speakerImage: String = "",
            joinedCount: Int? = null
        ): Intent {
            return Intent(context, WalkieIncomingActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP or
                        Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
                putExtra("speaker_name", speakerName)
                putExtra("group_name", groupName)
                putExtra("group_id", groupId)
                putExtra("speaker_image", speakerImage)
                if (joinedCount != null) {
                    putExtra("joined_count", joinedCount)
                }
            }
        }
    }

    private val timeoutHandler = Handler(Looper.getMainLooper())
    private val dismissRunnable = Runnable {
        Log.d(TAG, "Auto-dismissing WalkieIncomingActivity after timeout")
        finishAndRemoveTask()
    }

    private var currentGroupId: String = ""
    private var currentGroupName: String = ""
    private var currentSpeakerName: String = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Allow displaying over lock screen and wake device screen
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        setContentView(R.layout.activity_walkie_incoming)

        populateFromIntent(intent)

        timeoutHandler.postDelayed(dismissRunnable, AUTO_DISMISS_DELAY_MS)
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        setIntent(intent)
        timeoutHandler.removeCallbacks(dismissRunnable)
        populateFromIntent(intent)
        timeoutHandler.postDelayed(dismissRunnable, AUTO_DISMISS_DELAY_MS)
    }

    private fun populateFromIntent(intent: Intent?) {
        if (intent == null) return

        currentGroupId = intent.getStringExtra("group_id") ?: ""
        currentGroupName = intent.getStringExtra("group_name") ?: "Field Team"
        currentSpeakerName = intent.getStringExtra("speaker_name") ?: "Someone"
        val joinedCount = intent.getIntExtra("joined_count", -1)

        val groupTextView = findViewById<TextView>(R.id.notification_group_name)
        val speakerTextView = findViewById<TextView>(R.id.notification_speaker_subtext)
        val joinedCountTextView = findViewById<TextView>(R.id.notification_joined_count)
        val btnAccept = findViewById<TextView>(R.id.btn_accept)
        val btnCancel = findViewById<TextView>(R.id.btn_cancel)

        groupTextView?.text = if (currentGroupName.trim().isNotEmpty()) currentGroupName.trim() else "Field Team"
        speakerTextView?.text = if (currentSpeakerName.trim().isNotEmpty()) {
            "${currentSpeakerName.trim()} is speaking..."
        } else {
            "Someone is speaking..."
        }

        if (joinedCount > 0) {
            joinedCountTextView?.text = "👥 $joinedCount Joined"
        } else {
            joinedCountTextView?.text = "👥 Active"
        }

        btnCancel?.setOnClickListener {
            handleCancel()
        }

        btnAccept?.setOnClickListener {
            handleAccept()
        }
    }

    private fun handleCancel() {
        timeoutHandler.removeCallbacks(dismissRunnable)

        // Cancel status-bar notification
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        nm?.cancel(WalkieCustomNotificationPlugin.NOTIFICATION_ID)

        // Send broadcast so background/engine is informed
        val rejectIntent = Intent(this, WalkieActionReceiver::class.java).apply {
            action = WalkieCustomNotificationPlugin.ACTION_REJECT
            putExtra("group_id", currentGroupId)
            putExtra("group_name", currentGroupName)
            putExtra("speaker_name", currentSpeakerName)
        }
        sendBroadcast(rejectIntent)

        finishAndRemoveTask()
    }

    private fun handleAccept() {
        timeoutHandler.removeCallbacks(dismissRunnable)

        // Cancel status-bar notification
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        nm?.cancel(WalkieCustomNotificationPlugin.NOTIFICATION_ID)

        // Launch MainActivity and navigate directly to the Walkie Screen
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("walkie_action", "accept")
            putExtra("group_id", currentGroupId)
            putExtra("group_name", currentGroupName)
            putExtra("speaker_name", currentSpeakerName)
        }
        if (launchIntent != null) {
            startActivity(launchIntent)
        }

        finishAndRemoveTask()
    }

    override fun onDestroy() {
        timeoutHandler.removeCallbacks(dismissRunnable)
        super.onDestroy()
    }
}
