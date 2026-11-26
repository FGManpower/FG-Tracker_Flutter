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
        val callerId = extractCallerId(intent)
        val userId = extractUserId(intent) ?: readUserId(context)

        Log.d(TAG, "ACTION_CALL_DECLINE received action=$action callId=$callId groupId=$groupId callerId=$callerId userId=$userId")

        if ((callId.isNullOrBlank() || callId == "null") && (callerId.isNullOrBlank() && userId.isNullOrBlank())) {
            Log.e(TAG, "ABORTED — no callId, callerId, or userId found to decline")
            return
        }

        val deDupeKey = callId?.takeIf { it.isNotBlank() && it != "null" } ?: "user_${userId}_caller_${callerId}"
        if (!inFlightOrHandledCallIds.add(deDupeKey)) {
            Log.d(TAG, "Skipping duplicate native decline for key=$deDupeKey")
            return
        }

        val pendingResult = goAsync()
        val appContext = context.applicationContext

        executor.execute {
            try {
                rejectCallViaApi(appContext, callId, groupId, callerId, userId)
            } catch (e: Exception) {
                inFlightOrHandledCallIds.remove(deDupeKey)
                Log.e(TAG, "rejectCallViaApi exception: ${e.message}", e)
            } finally {
                pendingResult.finish()
            }
        }
    }

    private fun rejectCallViaApi(
        context: Context,
        callId: String?,
        groupId: String?,
        callerId: String? = null,
        userId: String? = null
    ) {
        val token = readAccessToken(context)
        val query = StringBuilder()
        if (!callId.isNullOrBlank() && callId != "null") {
            query.append("callId=").append(URLEncoder.encode(callId, "UTF-8"))
        }
        if (!groupId.isNullOrBlank() && groupId != "null") {
            if (query.isNotEmpty()) query.append("&")
            query.append("groupId=").append(URLEncoder.encode(groupId, "UTF-8"))
        } else {
            if (query.isNotEmpty()) query.append("&")
            query.append("reason=declined")
        }
        if (!callerId.isNullOrBlank() && callerId != "null") {
            if (query.isNotEmpty()) query.append("&")
            query.append("callerId=").append(URLEncoder.encode(callerId, "UTF-8"))
        }
        val effectiveUserId = userId ?: readUserId(context)
        if (!effectiveUserId.isNullOrBlank() && effectiveUserId != "null") {
            if (query.isNotEmpty()) query.append("&")
            query.append("userId=").append(URLEncoder.encode(effectiveUserId, "UTF-8"))
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
                if (!token.isNullOrBlank()) {
                    setRequestProperty("Authorization", "Bearer $token")
                }
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
            map?.get("call_id")?.toString()?.takeIf { it.isNotBlank() && it != "null" }?.let {
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
        topExtra?.get("call_id")?.toString()?.takeIf { it.isNotBlank() && it != "null" }?.let {
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
            map?.get("group_id")?.toString()?.takeIf { it.isNotBlank() && it != "null" }?.let {
                return it
            }
        }

        val topExtra = intent.getSerializableExtra("EXTRA_CALLKIT_EXTRA") as? Map<*, *>
        return topExtra?.get("groupId")?.toString()?.takeIf { it.isNotBlank() && it != "null" }
            ?: topExtra?.get("group_id")?.toString()?.takeIf { it.isNotBlank() && it != "null" }
    }

    @Suppress("DEPRECATION")
    private fun extractCallerId(intent: Intent): String? {
        intent.getStringExtra("callerId")?.takeIf { it.isNotBlank() && it != "null" }?.let { return it }
        intent.getStringExtra("caller_id")?.takeIf { it.isNotBlank() && it != "null" }?.let { return it }

        val dataBundle: Bundle? = intent.extras?.getBundle("EXTRA_CALLKIT_INCOMING_DATA")
        if (dataBundle != null) {
            val map = dataBundle.getSerializable("EXTRA_CALLKIT_EXTRA") as? Map<*, *>
            map?.get("callerId")?.toString()?.takeIf { it.isNotBlank() && it != "null" }?.let { return it }
            map?.get("caller_id")?.toString()?.takeIf { it.isNotBlank() && it != "null" }?.let { return it }
        }

        val topExtra = intent.getSerializableExtra("EXTRA_CALLKIT_EXTRA") as? Map<*, *>
        return topExtra?.get("callerId")?.toString()?.takeIf { it.isNotBlank() && it != "null" }
            ?: topExtra?.get("caller_id")?.toString()?.takeIf { it.isNotBlank() && it != "null" }
    }

    @Suppress("DEPRECATION")
    private fun extractUserId(intent: Intent): String? {
        intent.getStringExtra("userId")?.takeIf { it.isNotBlank() && it != "null" }?.let { return it }
        intent.getStringExtra("user_id")?.takeIf { it.isNotBlank() && it != "null" }?.let { return it }

        val dataBundle: Bundle? = intent.extras?.getBundle("EXTRA_CALLKIT_INCOMING_DATA")
        if (dataBundle != null) {
            val map = dataBundle.getSerializable("EXTRA_CALLKIT_EXTRA") as? Map<*, *>
            map?.get("userId")?.toString()?.takeIf { it.isNotBlank() && it != "null" }?.let { return it }
            map?.get("user_id")?.toString()?.takeIf { it.isNotBlank() && it != "null" }?.let { return it }
        }

        val topExtra = intent.getSerializableExtra("EXTRA_CALLKIT_EXTRA") as? Map<*, *>
        return topExtra?.get("userId")?.toString()?.takeIf { it.isNotBlank() && it != "null" }
            ?: topExtra?.get("user_id")?.toString()?.takeIf { it.isNotBlank() && it != "null" }
    }

    companion object {
        private const val TAG = "CallDeclineReceiver"
        // VPS Testing Server host as the Dart app (ConstRes.aBaseUrl)
        private const val BASE_URL = "http://89.116.23.2:3000/api"

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

        fun readUserId(context: Context): String? {
            val flutterPrefs =
                context.getSharedPreferences(FLUTTER_PREFS_NAME, Context.MODE_PRIVATE)
            val candidateKeys = listOf(
                "flutter.userId",
                "userId",
                "flutter.user_id",
                "user_id",
                "flutter.profile_id",
                "profile_id"
            )
            for (key in candidateKeys) {
                val value = flutterPrefs.getString(key, null)
                if (!value.isNullOrBlank()) return value
                val intVal = try { flutterPrefs.getInt(key, -1) } catch (_: Exception) { -1 }
                if (intVal > 0) return intVal.toString()
                val longVal = try { flutterPrefs.getLong(key, -1L) } catch (_: Exception) { -1L }
                if (longVal > 0L) return longVal.toString()
            }
            return null
        }
    }
}