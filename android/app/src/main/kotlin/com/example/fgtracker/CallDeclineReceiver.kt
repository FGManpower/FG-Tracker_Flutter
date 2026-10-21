package com.example.fgtracker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder
import java.util.Collections
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.Executors

class CallDeclineReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        val expectedNativeAction = "${context.packageName}.ACTION_NATIVE_CALL_DECLINE"
        val expectedPluginAction = "${context.packageName}.$PLUGIN_DECLINE_ACTION"

        if (
            action != expectedNativeAction &&
            action != PLUGIN_DECLINE_ACTION &&
            action != expectedPluginAction
        ) {
            return
        }

        val callId = extractCallId(intent)
        val groupId = extractGroupId(intent)

        Log.d(TAG, "ACTION_CALL_DECLINE received action=$action callId=$callId groupId=$groupId")

        if (callId.isNullOrBlank() || callId == "null") {
            Log.e(TAG, "ABORTED — callId is missing in intent")
            return
        }

        if (!inFlightOrHandledCallIds.add(callId)) {
            Log.d(TAG, "Skipping duplicate native decline for callId=$callId")
            return
        }

        val pendingResult = goAsync()
        val appContext = context.applicationContext

        executor.execute {
            try {
                rejectCallViaApi(appContext, callId, groupId)
            } catch (e: Exception) {
                inFlightOrHandledCallIds.remove(callId)
                Log.e(TAG, "rejectCallViaApi exception: ${e.message}", e)
            } finally {
                pendingResult.finish()
            }
        }
    }

    private fun rejectCallViaApi(context: Context, callId: String, groupId: String?) {
        val token = readAccessToken(context)
        if (token.isNullOrBlank()) {
            val flutterPrefs =
                context.getSharedPreferences(FLUTTER_PREFS_NAME, Context.MODE_PRIVATE)
            Log.e(
                TAG,
                "ABORTED — access token not found. Available FlutterSharedPreferences keys=" +
                        "${flutterPrefs.all.keys}"
            )
            return
        }

        val query = StringBuilder("callId=").append(URLEncoder.encode(callId, "UTF-8"))
        if (!groupId.isNullOrBlank() && groupId != "null") {
            query.append("&groupId=").append(URLEncoder.encode(groupId, "UTF-8"))
        }

        val urlString = "$BASE_URL/callRejected?$query"
        Log.d(TAG, "Sending GET $urlString")

        var conn: HttpURLConnection? = null
        try {
            conn = (URL(urlString).openConnection() as HttpURLConnection).apply {
                requestMethod = "GET"
                connectTimeout = 8000
                readTimeout = 8000
                setRequestProperty("Content-Type", "application/json")
                setRequestProperty("Accept", "application/json")
                setRequestProperty("Authorization", "Bearer $token")
            }

            val status = conn.responseCode
            val responseBody = try {
                conn.inputStream?.bufferedReader()?.use { it.readText() } ?: ""
            } catch (_: Exception) {
                conn.errorStream?.bufferedReader()?.use { it.readText() } ?: ""
            }

            Log.d(TAG, "HTTP status=$status body=$responseBody")
        } finally {
            conn?.disconnect()
        }
    }

    @Suppress("DEPRECATION")
    private fun extractCallId(intent: Intent): String? {
        intent.getStringExtra(EXTRA_CALL_ID)
            ?.takeIf { it.isNotBlank() && it != "null" }
            ?.let { return it }

        val dataBundle: Bundle? = intent.extras?.getBundle("EXTRA_CALLKIT_INCOMING_DATA")
        if (dataBundle != null) {
            val map = dataBundle.getSerializable("EXTRA_CALLKIT_EXTRA") as? Map<*, *>
            map?.get("callId")?.toString()?.takeIf { it.isNotBlank() && it != "null" }?.let {
                return it
            }
            dataBundle.getString("EXTRA_CALLKIT_ID")
                ?.takeIf { it.isNotBlank() && it != "null" }
                ?.let { return it }
        }

        val topExtra = intent.getSerializableExtra("EXTRA_CALLKIT_EXTRA") as? Map<*, *>
        topExtra?.get("callId")?.toString()?.takeIf { it.isNotBlank() && it != "null" }?.let {
            return it
        }

        return intent.getStringExtra("id")
    }

    @Suppress("DEPRECATION")
    private fun extractGroupId(intent: Intent): String? {
        intent.getStringExtra(EXTRA_GROUP_ID)
            ?.takeIf { it.isNotBlank() && it != "null" }
            ?.let { return it }

        val dataBundle: Bundle? = intent.extras?.getBundle("EXTRA_CALLKIT_INCOMING_DATA")
        if (dataBundle != null) {
            val map = dataBundle.getSerializable("EXTRA_CALLKIT_EXTRA") as? Map<*, *>
            map?.get("groupId")?.toString()?.takeIf { it.isNotBlank() && it != "null" }?.let {
                return it
            }
        }

        val topExtra = intent.getSerializableExtra("EXTRA_CALLKIT_EXTRA") as? Map<*, *>
        return topExtra?.get("groupId")?.toString()?.takeIf { it.isNotBlank() && it != "null" }
    }

    companion object {
        private const val TAG = "CallDeclineReceiver"
        private const val BASE_URL = "http://fgtracker.in:3000/api"

        private const val FLUTTER_PREFS_NAME = "FlutterSharedPreferences"
        private const val PLUGIN_DECLINE_ACTION =
            "com.hiennv.flutter_callkit_incoming.ACTION_CALL_DECLINE"
        private const val EXTRA_CALL_ID = "callId"
        private const val EXTRA_GROUP_ID = "groupId"

        private val executor = Executors.newSingleThreadExecutor()
        private val inFlightOrHandledCallIds: MutableSet<String> =
            Collections.newSetFromMap(ConcurrentHashMap<String, Boolean>())

        fun enqueueDecline(context: Context, callId: String?, groupId: String?) {
            val intent = Intent(context, CallDeclineReceiver::class.java).apply {
                action = "${context.packageName}.ACTION_NATIVE_CALL_DECLINE"
                `package` = context.packageName
                putExtra(EXTRA_CALL_ID, callId)
                putExtra(EXTRA_GROUP_ID, groupId)
            }
            context.sendBroadcast(intent)
        }

        fun readAccessToken(context: Context): String? {
            val flutterPrefs =
                context.getSharedPreferences(FLUTTER_PREFS_NAME, Context.MODE_PRIVATE)
            val candidateFlutterKeys = listOf(
                "flutter.user_token_key",
                "user_token_key",
                "flutter.native_access_token",
                "flutter.token",
                "flutter.access_token"
            )
            for (key in candidateFlutterKeys) {
                val value = flutterPrefs.getString(key, null)
                if (!value.isNullOrBlank()) return value
            }

            val defaultPrefs = context.getSharedPreferences(
                "${context.packageName}_preferences",
                Context.MODE_PRIVATE
            )
            for (key in listOf("user_token_key", "flutter.user_token_key")) {
                val value = defaultPrefs.getString(key, null)
                if (!value.isNullOrBlank()) return value
            }

            return null
        }
    }
}