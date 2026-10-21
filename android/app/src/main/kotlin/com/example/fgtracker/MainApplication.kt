package com.example.fgtracker

import android.app.Activity
import android.app.Application
import android.os.Bundle
import android.util.Log
import com.hiennv.flutter_callkit_incoming.CallkitEventCallback
import com.hiennv.flutter_callkit_incoming.FlutterCallkitIncomingPlugin

private const val TAG = "MainApplication"

class MainApplication : Application() {

    @Volatile
    private var activeMainActivities: Int = 0

    val isMainAppRunning: Boolean
        get() = activeMainActivities > 0


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
                    if (isMainAppRunning) {
                        Log.d(
                            TAG,
                            "Skipping native REST decline — Flutter app is alive; " +
                                    "Dart socket handles single decline path"
                        )
                        return
                    }

                    val callId = extractCallId(callData)
                    val groupId = extractGroupId(callData)
                    Log.d(
                        TAG,
                        "Terminated-state DECLINE -> forwarding to CallDeclineReceiver " +
                                "callId=$callId groupId=$groupId"
                    )
                    CallDeclineReceiver.enqueueDecline(this@MainApplication, callId, groupId)
                }

                else -> {
                    Log.d(TAG, "Unhandled CallKit native event: $event")
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
                }
            }

            override fun onActivityDestroyed(activity: Activity) {
                if (activity is MainActivity) {
                    activeMainActivities = (activeMainActivities - 1).coerceAtLeast(0)
                    Log.d(TAG, "MainActivity destroyed -> activeMainActivities=$activeMainActivities")
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