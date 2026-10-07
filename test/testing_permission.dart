// <manifest xmlns:tools="http://schemas.android.com/tools"
// xmlns:android="http://schemas.android.com/apk/res/android"
// package="com.example.fgtracker">
//
// <uses-feature
// android:name="android.hardware.camera.any"
// tools:ignore="ManifestOrder" />
//
// <uses-feature android:name="android.hardware.camera"
// tools:ignore="DuplicateUsesFeature" />
//
// <uses-feature android:name="android.hardware.camera.autofocus"
// android:required="false"
// tools:targetApi="eclair" />
//
//
// <uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
// <uses-permission android:name="android.permission.INTERNET"/>
// <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
// <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
// <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
// <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
// <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
// <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
// <uses-permission android:name="com.google.android.gms.permission.AD_ID"/>
// <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
// <uses-permission android:name="android.permission.RECORD_AUDIO"/>
// <uses-permission android:name="android.permission.CAMERA"/>
// <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
// <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
// <uses-permission android:name="android.permission.BLUETOOTH" />
// <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
// <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
// <uses-permission android:name="android.permission.VIBRATE" />
// <uses-permission android:name="android.permission.WAKE_LOCK" />
// <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
// <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
// <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MICROPHONE" />
// <uses-permission android:name="android.permission.FOREGROUND_SERVICE_PHONE_CALL" />
// <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
// <uses-permission android:name="android.permission.READ_CONTACTS"/>
// <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION" />
//
// <application
// android:label="FG Tracker"
// android:name="${applicationName}"
// android:icon="@mipmap/ic_launcher"
// android:usesCleartextTraffic="true"
// android:foregroundServiceType="location|microphone"
// android:requestLegacyExternalStorage="true"
// android:enableOnBackInvokedCallback="true"
// android:allowBackup="false"
// android:fullBackupContent="false"
// tools:targetApi="31">
//
// <meta-data
// android:name="com.fg.fgtracker"
// android:resource="@mipmap/ic_launcher" />
// <meta-data
// android:name="com.pravera.flutter_foreground_task.notification_icon"
// android:resource="@mipmap/ic_launcher" />
//
// <activity
// android:name=".MainActivity"
// android:exported="true"
// android:launchMode="singleTask"
// android:taskAffinity=""
// android:theme="@style/LaunchTheme"
// android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
// android:hardwareAccelerated="true"
// android:windowSoftInputMode="adjustResize"
// android:showWhenLocked="true"
// android:turnScreenOn="true"
// tools:targetApi="33">
//
// <meta-data
// android:name="io.flutter.embedding.android.NormalTheme"
// android:resource="@style/NormalTheme" />
//
// <intent-filter>
// <action android:name="android.intent.action.MAIN"/>
// <category android:name="android.intent.category.LAUNCHER"/>
// </intent-filter>
//
// <!-- Deep Links -->
// <meta-data
// android:name="flutter_deeplinking_enabled"
// android:value="true" />
//
// <intent-filter>
// <action android:name="android.intent.action.VIEW" />
// <category android:name="android.intent.category.DEFAULT" />
// <category android:name="android.intent.category.BROWSABLE" />
// <data
// android:host="fgtracker.in"
// android:scheme="https" />
// </intent-filter>
//
// <!-- App Links -->
// <intent-filter android:autoVerify="true">
// <action android:name="android.intent.action.VIEW" />
// <category android:name="android.intent.category.DEFAULT" />
// <category android:name="android.intent.category.BROWSABLE" />
// <data
// android:host="fgtracker.in"
// android:scheme="https" />
// </intent-filter>
//
// </activity>
//
// <activity
// android:name="com.yalantis.ucrop.UCropActivity"
// android:screenOrientation="fullSensor"
// android:theme="@style/Theme.AppCompat.Light.NoActionBar" />
//
// <meta-data
// android:name="com.google.firebase.messaging.default_notification_channel_id"
// android:value="high_importance_channel" />
//
// <meta-data
// android:name="flutterEmbedding"
// android:value="2" />
//
// <meta-data
// android:name="com.google.android.geo.API_KEY"
// android:value="AIzaSyAgt-V8kmcQJb_6Cj6LHArWfhWjVPh7N_Q"/>
//
// <service
// android:name="com.lyokone.location.FlutterLocationService"
// android:exported="false"
// android:enabled="true"
// android:foregroundServiceType="location" />
//
// <!-- Corrected to allow both phoneCall and microphone access in background -->
// <service
// android:name="com.connectycube.flutter.calls.CallService"
// android:exported="false"
// android:foregroundServiceType="phoneCall|microphone" />
//
// <!-- Corrected to ensure background media, location, and microphone stay authorized -->
// <service
// android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
// android:enabled="true"
// android:exported="false"
// android:stopWithTask="false"
// android:foregroundServiceType="mediaProjection|microphone|location"
// tools:replace="android:foregroundServiceType" />
//
// <meta-data
// android:name="com.facebook.sdk.ApplicationId"
// android:value="@string/facebook_app_id"/>
//
// <meta-data
// android:name="com.facebook.sdk.ClientToken"
// android:value="@string/facebook_client_token"/>
//
// <meta-data
// android:name="com.facebook.sdk.AutoLogAppEventsEnabled"
// android:value="true"/>
//
// <meta-data
// android:name="com.facebook.sdk.a"
// android:value="true"/>
//
// <provider
// android:name="com.facebook.FacebookContentProvider"
// android:authorities="com.facebook.app.FacebookContentProvider2087541501869419"
// android:exported="true"/>
//
// <activity
// android:name="com.facebook.FacebookActivity"
// android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
// android:label="@string/app_name" />
//
// </application>
//
// <queries>
// <intent>
// <action android:name="android.intent.action.PROCESS_TEXT"/>
// <data android:mimeType="text/plain"/>
// </intent>
// <intent>
// <action android:name="android.intent.action.VIEW"/>
// <data android:scheme="https"/>
// </intent>
// <intent>
// <action android:name="android.intent.action.VIEW"/>
// <data android:scheme="http"/>
// </intent>
// </queries>
// </manifest>