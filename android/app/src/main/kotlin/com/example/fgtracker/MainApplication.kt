package com.example.fgtracker

import android.app.Activity
import android.app.Application
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.hiennv.flutter_callkit_incoming.CallkitEventCallback
import com.hiennv.flutter_callkit_incoming.FlutterCallkitIncomingPlugin
import java.lang.ref.WeakReference
import java.util.Collections

private const val TAG = "MainApplication"
private const val CALLKIT_INCOMING_ACTIVITY =
    "com.hiennv.flutter_callkit_incoming.CallkitIncomingActivity"
private const val ACTION_ENDED_CALL_INCOMING_SUFFIX =
    "com.hiennv.flutter_callkit_incoming.ACTION_ENDED_CALL_INCOMING"

class MainApplication : Application() {

    @Volatile
    private var activeMainActivities: Int = 0

    private val incomingCallActivities =
        Collections.synchronizedList(mutableListOf<WeakReference<Activity>>())

    val isMainAppRunning: Boolean
        get() = activeMainActivities > 0

    private fun closeIncomingCallActivities(): Boolean {
        var closedOpenActivity = false

        try {
            FlutterCallkitIncomingPlugin.getInstance()?.getCallkitSoundPlayerManager()?.stop()
        } catch (_: Exception) {}

        try {
            val closeBroadcast = Intent("${packageName}.$ACTION_ENDED_CALL_INCOMING_SUFFIX").apply {
                putExtra("ACCEPTED", false)
                setPackage(packageName)
            }
            sendBroadcast(closeBroadcast)
        } catch (e: Exception) {
            Log.e(TAG, "Failed sending close broadcast: ${e.message}")
        }

        val snapshot: List<Activity>
        synchronized(incomingCallActivities) {
            snapshot = incomingCallActivities.mapNotNull { it.get() }
            incomingCallActivities.clear()
        }

        for (act in snapshot) {
            if (!act.isFinishing && !act.isDestroyed) {
                closedOpenActivity = true
            }
        }

        Handler(Looper.getMainLooper()).post {
            for (act in snapshot) {
                try {
                    if (!act.isFinishing && !act.isDestroyed) {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                            act.finishAndRemoveTask()
                        } else {
                            act.finish()
                        }
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error finishing CallkitIncomingActivity: ${e.message}")
                }
            }
        }

        return closedOpenActivity
    }

    private val callkitEventCallback = object : CallkitEventCallback {
        override fun onCallEvent(event: CallkitEventCallback.CallEvent, callData: Bundle) {
            Log.d(
                TAG,
                "onCallEvent=$event isMainAppRunning=$isMainAppRunning " +
                        "(activeMainActivities=$activeMainActivities)"
            )

            when (event) {
                CallkitEventCallback.CallEvent.ACCEPT -> {
                    Log.d(TAG, "onAccept received natively")
                }

                CallkitEventCallback.CallEvent.DECLINE -> {
                    val closedProgrammatically = closeIncomingCallActivities()
                    val callId = extractCallId(callData)
                    val groupId = extractGroupId(callData)
                    if (!isMainAppRunning && !closedProgrammatically) {
                        Log.d(
                            TAG,
                            "DECLINE by user while terminated -> CallDeclineReceiver " +
                                    "callId=$callId groupId=$groupId"
                        )
                        CallDeclineReceiver.enqueueDecline(this@MainApplication, callId, groupId)
                    } else {
                        Log.d(
                            TAG,
                            "DECLINE handled (isMainAppRunning=$isMainAppRunning " +
                                    "closedProgrammatically=$closedProgrammatically callId=$callId)"
                        )
                    }
                }

                CallkitEventCallback.CallEvent.END -> {
                    closeIncomingCallActivities()
                }
            }
        }
    }

    override fun onCreate() {
        super.onCreate()

        registerActivityLifecycleCallbacks(object : ActivityLifecycleCallbacks {
            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
                if (activity is MainActivity) {
                    activeMainActivities += 1
                    Log.d(TAG, "MainActivity created -> activeMainActivities=$activeMainActivities")
                } else if (activity.javaClass.name == CALLKIT_INCOMING_ACTIVITY) {
                    incomingCallActivities.add(WeakReference(activity))
                    Log.d(TAG, "Tracked CallkitIncomingActivity instance")
                }
            }

            override fun onActivityDestroyed(activity: Activity) {
                if (activity is MainActivity) {
                    activeMainActivities = (activeMainActivities - 1).coerceAtLeast(0)
                    Log.d(TAG, "MainActivity destroyed -> activeMainActivities=$activeMainActivities")
                } else if (activity.javaClass.name == CALLKIT_INCOMING_ACTIVITY) {
                    synchronized(incomingCallActivities) {
                        incomingCallActivities.removeAll { it.get() == null || it.get() == activity }
                    }
                }
            }

            override fun onActivityStarted(activity: Activity) {}
            override fun onActivityResumed(activity: Activity) {}
            override fun onActivityPaused(activity: Activity) {}
            override fun onActivityStopped(activity: Activity) {}
            override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
        })

        FlutterCallkitIncomingPlugin.registerEventCallback(callkitEventCallback)
        val tokenPresent = CallDeclineReceiver.readAccessToken(this) != null
        Log.d(TAG, "MainApplication.onCreate complete (tokenPresent=$tokenPresent)")
    }

    @Suppress("DEPRECATION")
    private fun extractCallId(callData: Bundle): String? {
        val extra = callData.getSerializable("EXTRA_CALLKIT_EXTRA") as? Map<*, *>
        extra?.get("callId")?.toString()?.takeIf { it.isNotBlank() && it != "null" }?.let {
            return it
        }
        callData.getString("callId")?.takeIf { it.isNotBlank() && it != "null" }?.let {
            return it
        }
        return callData.getString("EXTRA_CALLKIT_ID")?.takeIf { it.isNotBlank() && it != "null" }
    }

    @Suppress("DEPRECATION")
    private fun extractGroupId(callData: Bundle): String? {
        val extra = callData.getSerializable("EXTRA_CALLKIT_EXTRA") as? Map<*, *>
        extra?.get("groupId")?.toString()?.takeIf { it.isNotBlank() && it != "null" }?.let {
            return it
        }
        return callData.getString("groupId")?.takeIf { it.isNotBlank() && it != "null" }
    }
}

