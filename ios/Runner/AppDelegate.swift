import UIKit
import Foundation
import Flutter
import Firebase
import GoogleMaps
import PushKit
import CallKit
import AVFAudio
import AVFoundation
import UserNotifications
import Intents
import CryptoKit
import WebRTC
import flutter_callkit_incoming

// private let apiBaseUrl = "http://10.57.204.163:4000/api"
private let apiBaseUrl = "http://fgtracker.in:3000/api"
private let callingStatusEndpoints = ["/calling-status"]
private let candidateTokenPrefKeys = [
    "flutter.user_token_key",
    "user_token_key",
    "flutter.native_access_token",
    "flutter.token",
    "flutter.access_token"
]

@main
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate, CallkitIncomingAppDelegate {

    private var voipRegistry: PKPushRegistry?
    private var audioRouteChannel: FlutterMethodChannel?
    private var hasLaunchedIntoForeground = false
    private var enteredBackgroundAt: Date?
    private let socketSuspensionThresholdSeconds: TimeInterval = 25.0
    private var audioGeneration = 0
    private var currentCallIsVideo = false
    private var manualAudioRoute: String?
    private var bluetoothKnownName: String?
    private var bluetoothSeenInCall = false
    private var routeObserverToken: NSObjectProtocol?
    private var isApplyingAudioRoute = false
    private var routeChangeQuietUntil: Date?
    private let routeChangeQuietWindow: TimeInterval = 0.45
    private var userSelectedRoute = false
    private var lastAppliedRoute: String?
    private var lastAppliedAt: Date?
    private let duplicateApplyWindow: TimeInterval = 0.4
    private var lastCategoryKey: String?

    private var activeBgTasks: [UUID: UIBackgroundTaskIdentifier] = [:]
    private var handledDeclineCallIds = Set<String>()
    private var handledRingingCallIds = Set<String>()
    private var callDisplayNames: [String: String] = [:]
    private var pendingRecentsCallback: [String: Any]?
    private var deferredRouteCheck: DispatchWorkItem?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        GMSServices.provideAPIKey("AIzaSyAgt-V8kmcQJb_6Cj6LHArWfhWjVPh7N_Q")
        GeneratedPluginRegistrant.register(with: self)

        configureDefaultWebRTCAudio(isVideo: false)

        let mainQueue = DispatchQueue.main
        let registry = PKPushRegistry(queue: mainQueue)
        registry.delegate = self
        registry.desiredPushTypes = [PKPushType.voIP]
        self.voipRegistry = registry

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }

        let launched = super.application(application, didFinishLaunchingWithOptions: launchOptions)
        setupAudioRouteChannelIfNeeded()
        return launched
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        hasLaunchedIntoForeground = true
        enteredBackgroundAt = nil
        setupAudioRouteChannelIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.flushRecentsCallback()
        }
        super.applicationDidBecomeActive(application)
    }

    override func applicationDidEnterBackground(_ application: UIApplication) {
        enteredBackgroundAt = Date()
        super.applicationDidEnterBackground(application)
    }

    override func applicationWillTerminate(_ application: UIApplication) {
        hasLaunchedIntoForeground = false
        super.applicationWillTerminate(application)
    }

    private func setupAudioRouteChannelIfNeeded() {
        guard audioRouteChannel == nil,
              let vc = window?.rootViewController as? FlutterViewController else {
            return
        }
        let channel = FlutterMethodChannel(
            name: "com.fgtracker.audio_route",
            binaryMessenger: vc.binaryMessenger
        )
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else {
                result(nil)
                return
            }
            switch call.method {
            case "setAudioRoute":
                let args = call.arguments as? [String: Any]
                let route = (args?["route"] as? String) ?? "earpiece"
                let isVideo = (args?["isVideo"] as? Bool) ?? self.currentCallIsVideo
                let isManual = (args?["isManual"] as? Bool) ?? true
                let force = (args?["force"] as? Bool) ?? false
                let state = self.applyRequestedAudioRoute(
                    route: route,
                    isVideo: isVideo,
                    userInitiated: isManual,
                    force: force
                )
                result(state)
            case "getAudioState":
                result(self.readAudioState())
            case "getScreenCaptureState":
                var payload: [String: Any] = [
                    "isCaptured": UIScreen.main.isCaptured
                ]
                if let group = Bundle.main.object(
                    forInfoDictionaryKey: "RTCAppGroupIdentifier"
                ) as? String {
                    payload["appGroup"] = group
                }
                if let ext = Bundle.main.object(
                    forInfoDictionaryKey: "RTCScreenSharingExtension"
                ) as? String {
                    payload["extension"] = ext
                }
                var groupOK = false
                if let group = payload["appGroup"] as? String {
                    groupOK = FileManager.default.containerURL(
                        forSecurityApplicationGroupIdentifier: group
                    ) != nil
                }
                payload["appGroupAccessible"] = groupOK
                result(payload)
            case "resetAudioRoute":
                self.manualAudioRoute = nil
                self.bluetoothKnownName = nil
                self.bluetoothSeenInCall = false
                self.userSelectedRoute = false
                self.lastAppliedRoute = nil
                self.lastAppliedAt = nil
                self.lastCategoryKey = nil
                self.clearPreferredInputSelection()
                result(nil)
            case "startAudioRouteMonitoring":
                let args = call.arguments as? [String: Any]
                if let isVideo = args?["isVideo"] as? Bool {
                    self.currentCallIsVideo = isVideo
                }
                self.startAudioRouteMonitoring()
                result(self.readAudioState())
            case "stopAudioRouteMonitoring":
                self.stopAudioRouteMonitoring()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        audioRouteChannel = channel
    }

    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        if let vc = window?.rootViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(
                name: "com.yourapp.notifications",
                binaryMessenger: vc.binaryMessenger
            )
            channel.invokeMethod("handleDeepLink", arguments: url.absoluteString)
        }
        return super.application(app, open: url, options: options)
    }

    override func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        if handleRecentsCallback(userActivity) {
            return true
        }
        if let url = userActivity.webpageURL,
           let vc = window?.rootViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(
                name: "com.yourapp.notifications",
                binaryMessenger: vc.binaryMessenger
            )
            channel.invokeMethod("handleDeepLink", arguments: url.absoluteString)
            return true
        }
        return super.application(
            application,
            continue: userActivity,
            restorationHandler: restorationHandler
        )
    }

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        super.userNotificationCenter(
            center,
            willPresent: notification,
            withCompletionHandler: completionHandler
        )
    }

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.actionIdentifier == CallkitNotificationManager.CALLBACK_ACTION {
            let data = response.notification.request.content.userInfo as? [String: Any]
            SwiftFlutterCallkitIncomingPlugin.sharedInstance?.sendCallbackEvent(data)
            completionHandler()
        } else {
            super.userNotificationCenter(
                center,
                didReceive: response,
                withCompletionHandler: completionHandler
            )
        }
    }

    func pushRegistry(
        _ registry: PKPushRegistry,
        didUpdate credentials: PKPushCredentials,
        for type: PKPushType
    ) {
        guard type == .voIP else { return }
        let token = credentials.token.map { String(format: "%02x", $0) }.joined()
        print("[AppDelegate] PushKit VoIP token updated (len=\(token.count))")
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(token)
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        guard type == .voIP else { return }
        print("[AppDelegate] PushKit VoIP token invalidated")
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
    }

    func pushRegistry(
        _ registry: PKPushRegistry,
        didReceiveIncomingPushWith payload: PKPushPayload,
        for type: PKPushType,
        completion: @escaping () -> Void
    ) {
        guard type == .voIP else {
            print("[AppDelegate][VoIP] push type is NOT voip, ignoring")
            completion()
            return
        }

        let p = payload.dictionaryPayload
        print(
            "[AppDelegate][VoIP] PUSH RECEIVED keys=\(Array(p.keys.map { String(describing: $0) })) "
                + "appState=\(UIApplication.shared.applicationState.rawValue) "
                + "pluginReady=\(SwiftFlutterCallkitIncomingPlugin.sharedInstance != nil)"
        )

        let rawId = Self.stringValue(p["id"])
            ?? Self.stringValue(p["sessionId"])
            ?? Self.stringValue(p["session_id"])
        let id = Self.ensureValidUuid(rawId)

        let signal = Self.stringValue(p["signal_type"])
            ?? Self.stringValue(p["type_signal"])
            ?? Self.stringValue(p["action"])
            ?? "startCall"

        let avatar = Self.stringValue(p["avatar"]) ?? Self.stringValue(p["callerAvatar"]) ?? ""
        let isVideo = Self.parseIsVideo(p)

        var extraDict: [String: Any] = [:]
        if let nestedDict = p["extra"] as? [String: Any] {
            extraDict.merge(nestedDict) { _, new in new }
        } else if let nestedJson = p["extra"] as? String,
                  let jsonData = nestedJson.data(using: .utf8),
                  let parsed = (try? JSONSerialization.jsonObject(with: jsonData)) as? [String: Any] {
            extraDict.merge(parsed) { _, new in new }
        }
        for key in ["callId", "call_id", "caller_id", "groupId", "group_id", "sessionId", "session_id", "callerId", "callerPhone", "caller_phone", "phone", "mobile"] {
            if extraDict[key] == nil, let topVal = p[key] {
                extraDict[key] = topVal
            }
        }
        if extraDict["sessionId"] == nil {
            extraDict["sessionId"] = id
        }
        extraDict = sanitizedExtra(extraDict)

        let name = resolvedCallerName(payload: p, extra: extraDict, id: id)
        print("[AppDelegate][VoIP] parsed signal=\(signal) id=\(id) name=\(name) video=\(isVideo)")

        let endSignals: Set<String> = ["endCall", "callEnded", "cancelCall", "callRejected", "missedCall"]
        print("[AppDelegate][VoIP] branch=\(endSignals.contains(signal) ? "END" : "INCOMING")")
        if endSignals.contains(signal) {
            releaseCallKitManualAudio()
            let handleValue = resolvedCallerHandle(
                payload: p,
                extra: extraDict,
                fallbackName: name
            )
            let real = flutter_callkit_incoming.Data(
                id: id,
                nameCaller: name,
                handle: handleValue,
                type: isVideo ? 1 : 0
            )
            real.normalHandle = 1
            real.appName = "FG Tracker"

            if hasLiveCall(id: id) {
                print("[AppDelegate] endCall push resolves live CallKit call id=\(id) name=\(name)")
                SwiftFlutterCallkitIncomingPlugin.sharedInstance?.endCall(real)
                completion()
                return
            }

            let dummy = flutter_callkit_incoming.Data(
                id: id,
                nameCaller: name,
                handle: handleValue,
                type: isVideo ? 1 : 0
            )
            dummy.normalHandle = 1
            dummy.appName = "FG Tracker"
            print("[AppDelegate] endCall push had no live call, reporting+ending id=\(id) name=\(name)")
            SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(
                dummy,
                fromPushKit: true
            ) {
                print("[AppDelegate][VoIP] dummy reportNewIncomingCall returned id=\(id)")
                SwiftFlutterCallkitIncomingPlugin.sharedInstance?.endCall(dummy)
                SwiftFlutterCallkitIncomingPlugin.sharedInstance?.endCall(real)
                completion()
            }
        } else {
            manualAudioRoute = nil
            currentCallIsVideo = isVideo
            prepareCallKitManualAudio(isVideo: isVideo)

            let incomingCallId = Self.stringValue(extraDict["callId"])
                ?? Self.stringValue(extraDict["call_id"])
                ?? ""
            let callerIdInt = Int(
                Self.stringValue(extraDict["callerId"])
                    ?? Self.stringValue(extraDict["caller_id"])
                    ?? "0"
            ) ?? 0

            updateCallingStatusViaApi(
                callId: incomingCallId,
                remoteUserId: callerIdInt,
                callingStatus: "Ringing"
            )

            rememberCallerName(name, id: id, extra: extraDict)

            let data = flutter_callkit_incoming.Data(
                id: id,
                nameCaller: name,
                handle: resolvedCallerHandle(
                    payload: p,
                    extra: extraDict,
                    fallbackName: name
                ),
                type: isVideo ? 1 : 0
            )
            data.normalHandle = 1
            data.appName = "FG Tracker"
            data.supportsVideo = isVideo
            data.audioSessionMode = isVideo ? "videoChat" : "voiceChat"
            if !avatar.isEmpty {
                data.avatar = avatar
            }
            data.extra = NSDictionary(dictionary: extraDict)

            let plugin = SwiftFlutterCallkitIncomingPlugin.sharedInstance
            if plugin == nil {
                print("[AppDelegate][VoIP] CRITICAL plugin instance is nil -> call NOT reported, iOS will kill app")
            }
            plugin?.showCallkitIncoming(
                data,
                fromPushKit: true
            ) {
                print(
                    "[AppDelegate][VoIP] REPORTED to CallKit id=\(id) name=\(name) "
                        + "video=\(isVideo) state=\(UIApplication.shared.applicationState.rawValue)"
                )
                completion()
            }
        }
    }

    func onAccept(_ call: Call, _ action: CXAnswerCallAction) {
        print("[AppDelegate] onAccept")
        let isVideo = call.data.type == 1
        currentCallIsVideo = isVideo
        configureDefaultWebRTCAudio(isVideo: isVideo)
        audioGeneration += 1
        let expectedGen = audioGeneration
        RTCAudioSession.sharedInstance().useManualAudio = true
        action.fulfill()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
            guard let self = self, self.audioGeneration == expectedGen else { return }
            let rtcAudio = RTCAudioSession.sharedInstance()
            if !rtcAudio.isAudioEnabled {
                rtcAudio.audioSessionDidActivate(AVAudioSession.sharedInstance())
                rtcAudio.isAudioEnabled = true
            }
            if let manual = self.manualAudioRoute {
                _ = self.applyRequestedAudioRoute(
                    route: manual,
                    isVideo: self.currentCallIsVideo,
                    force: true
                )
            } else {
                self.applyInitialOutputPort(isVideo: isVideo)
            }
        }
    }

    func onDecline(_ call: Call, _ action: CXEndCallAction) {
        audioGeneration += 1
        releaseCallKitManualAudio()

        let extra = call.data.extra as? [String: Any] ?? [:]
        let callId = Self.stringValue(extra["callId"])
            ?? Self.stringValue(extra["call_id"])
            ?? ""
        let groupId = Self.stringValue(extra["groupId"])
            ?? Self.stringValue(extra["group_id"])

        print("[AppDelegate] onDecline callId=\(callId) groupId=\(groupId ?? "nil")")

        rejectCallViaApi(callId: callId, groupId: groupId)
        action.fulfill()
    }

    func onEnd(_ call: Call, _ action: CXEndCallAction) {
        print("[AppDelegate] onEnd")
        var bgTask: UIBackgroundTaskIdentifier = .invalid
        bgTask = UIApplication.shared.beginBackgroundTask(withName: "CallEndCleanup") {
            if bgTask != .invalid {
                UIApplication.shared.endBackgroundTask(bgTask)
                bgTask = .invalid
            }
        }
        audioGeneration += 1
        releaseCallKitManualAudio()
        action.fulfill()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if bgTask != .invalid {
                UIApplication.shared.endBackgroundTask(bgTask)
                bgTask = .invalid
            }
        }
    }

    func onTimeOut(_ call: Call) {
        print("[AppDelegate] onTimeOut")
        audioGeneration += 1
        releaseCallKitManualAudio()
    }

    func didActivateAudioSession(_ audioSession: AVAudioSession) {
        startAudioRouteMonitoring()
        configureDefaultWebRTCAudio(isVideo: currentCallIsVideo)
        let rtcAudio = RTCAudioSession.sharedInstance()
        rtcAudio.useManualAudio = true
        rtcAudio.audioSessionDidActivate(audioSession)
        rtcAudio.isAudioEnabled = true
        if let manual = manualAudioRoute {
            _ = applyRequestedAudioRoute(
                route: manual,
                isVideo: currentCallIsVideo,
                force: true
            )
        } else {
            applyInitialOutputPort(isVideo: currentCallIsVideo)
        }
    }

    func didDeactivateAudioSession(_ audioSession: AVAudioSession) {
        audioGeneration += 1
        manualAudioRoute = nil
        let rtcAudio = RTCAudioSession.sharedInstance()
        rtcAudio.audioSessionDidDeactivate(audioSession)
        rtcAudio.isAudioEnabled = false
        rtcAudio.useManualAudio = false
    }

    func providerDidReset() {
        print("[AppDelegate] providerDidReset")
        audioGeneration += 1
        releaseCallKitManualAudio()
        handledDeclineCallIds.removeAll()
        handledRingingCallIds.removeAll()
        callDisplayNames.removeAll()
    }

    private func resolvedCallerName(
        payload: [AnyHashable: Any],
        extra: [String: Any],
        id: String
    ) -> String {
        var candidates: [String?] = [
            Self.stringValue(payload["nameCaller"]),
            Self.stringValue(payload["callerName"]),
            Self.stringValue(payload["caller_name"]),
            Self.stringValue(extra["callerName"]),
            Self.stringValue(extra["caller_name"]),
            Self.stringValue(extra["nameCaller"]),
            Self.stringValue(payload["handle"]),
            Self.stringValue(payload["caller"]),
            callDisplayNames[id]
        ]
        for key in ["callId", "call_id", "sessionId", "session_id"] {
            if let value = Self.stringValue(extra[key]) {
                candidates.append(callDisplayNames[value])
            }
        }
        for candidate in candidates {
            if let display = Self.displayableName(candidate) {
                return display
            }
        }
        return "Unknown"
    }

    private func resolvedCallerHandle(
        payload: [AnyHashable: Any],
        extra: [String: Any],
        fallbackName: String
    ) -> String {
        let phoneKeys = ["callerPhone", "caller_phone", "phone", "mobile", "callerNumber"]
        for key in phoneKeys {
            if let value = Self.stringValue(extra[key]), !value.isEmpty {
                return value
            }
        }
        for key in phoneKeys {
            if let value = Self.stringValue(payload[key]), !value.isEmpty {
                return value
            }
        }
        if let supplied = Self.stringValue(payload["handle"]),
           !supplied.isEmpty,
           Self.displayableName(supplied) != nil {
            return supplied
        }
        for key in ["callerId", "caller_id"] {
            if let value = Self.stringValue(extra[key]), !value.isEmpty, value != "0" {
                return value
            }
        }
        if let display = Self.displayableName(fallbackName) {
            return display
        }
        return "Unknown"
    }

    private func sanitizedExtra(_ extra: [String: Any]) -> [String: Any] {
        let blocked = ["token", "jwt", "authorization", "bearer", "password", "secret", "cookie", "api_key", "apikey"]
        var clean: [String: Any] = [:]
        for (key, value) in extra {
            let lowered = key.lowercased()
            if blocked.contains(where: { lowered.contains($0) }) { continue }
            clean[key] = value
        }
        return clean
    }

    private func hasLiveCall(id: String) -> Bool {
        let observer = CXCallObserver()
        observer.setDelegate(nil, queue: nil)
        return observer.calls.contains {
            $0.uuid.uuidString.caseInsensitiveCompare(id) == .orderedSame
        }
    }

    private static func displayableName(_ raw: String?) -> String? {
        let trimmed = (raw ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }
        let rejected: Set<String> = ["someone", "unknown", "null", "nil", "none", "0"]
        if rejected.contains(trimmed.lowercased()) { return nil }
        if looksLikeToken(trimmed) { return nil }
        return trimmed
    }

    private static func looksLikeToken(_ value: String) -> Bool {
        if value.count < 32 { return false }
        if value.contains(" ") { return false }
        let allowed = CharacterSet(
            charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.=+/"
        )
        return value.unicodeScalars.allSatisfy { allowed.contains($0) }
    }

    private func rememberCallerName(_ name: String, id: String, extra: [String: Any]) {
        guard let trimmed = Self.displayableName(name) else { return }
        if callDisplayNames.count > 60 {
            callDisplayNames.removeAll()
        }
        callDisplayNames[id] = trimmed
        for key in ["callId", "call_id", "sessionId", "session_id"] {
            if let value = Self.stringValue(extra[key]), !value.isEmpty {
                callDisplayNames[value] = trimmed
            }
        }
        print("[AppDelegate] caller name cached id=\(id) name=\(trimmed)")
    }

    private func configureDefaultWebRTCAudio(isVideo: Bool) {
        let config = RTCAudioSessionConfiguration.webRTC()
        config.category = AVAudioSession.Category.playAndRecord.rawValue
        config.mode = isVideo
            ? AVAudioSession.Mode.videoChat.rawValue
            : AVAudioSession.Mode.voiceChat.rawValue
        config.categoryOptions = categoryOptions(
            forRoute: manualAudioRoute,
            isVideo: isVideo
        )
        RTCAudioSessionConfiguration.setWebRTC(config)
    }

    private func categoryOptions(
        forRoute route: String?,
        isVideo: Bool
    ) -> AVAudioSession.CategoryOptions {
        let name = route ?? ""

        if name == "earpiece" || name == "headset" {
            if shouldSuppressBluetooth(forRoute: name) {
                return []
            }
            return [.allowBluetooth, .allowBluetoothA2DP]
        }

        if name == "speaker" {
            return [.allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker]
        }

        if name == "bluetooth" {
            return [.allowBluetooth, .allowBluetoothA2DP]
        }

        return isVideo
            ? [.allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker]
            : [.allowBluetooth, .allowBluetoothA2DP]
    }

    private func bluetoothPort(
        in ports: [AVAudioSessionPortDescription]
    ) -> AVAudioSessionPortDescription? {
        return ports.first {
            $0.portType == .bluetoothHFP ||
                $0.portType == .bluetoothLE ||
                $0.portType == .carAudio
        }
    }

    private func currentBluetoothPort() -> AVAudioSessionPortDescription? {
        return bluetoothPort(in: AVAudioSession.sharedInstance().availableInputs ?? [])
    }

    private func isBluetoothSuppressed() -> Bool {
        return manualAudioRoute == "earpiece" || manualAudioRoute == "headset"
    }

    private func shouldSuppressBluetooth(forRoute route: String) -> Bool {
        guard route == "earpiece" || route == "headset" else { return false }
        guard userSelectedRoute else { return false }
        if let port = currentBluetoothPort() {
            rememberBluetoothPort(port)
            return true
        }
        bluetoothSeenInCall = false
        return false
    }

    private func evaluateBluetoothAvailability() {
        let session = AVAudioSession.sharedInstance()
        let inputs = session.availableInputs ?? []
        guard let port = bluetoothPort(in: inputs) else {
            print("[AppDelegate] bluetooth route not exposed yet (category options?)")
            return
        }
        rememberBluetoothPort(port)
        let autoSelect = shouldAutoSelectBluetooth() ||
            (manualAudioRoute == nil && !userSelectedRoute)
        guard autoSelect else {
            print("[AppDelegate] bluetooth available, keeping \(manualAudioRoute ?? "nil")")
            return
        }
        print("[AppDelegate] bluetooth connected -> auto selecting bluetooth")
        manualAudioRoute = "bluetooth"
        _ = applyRequestedAudioRoute(
            route: "bluetooth",
            isVideo: currentCallIsVideo
        )
    }

    private func reassertSpeakerOverrideIfNeeded() {
        guard manualAudioRoute == "speaker", !isApplyingAudioRoute else { return }
        let outputs = AVAudioSession.sharedInstance().currentRoute.outputs.map { $0.portType }
        let onSpeaker = outputs.contains(.builtInSpeaker)
        print("[AppDelegate] route check speaker onSpeaker=\(onSpeaker) outputs=\(outputs.map { $0.rawValue })")
        guard !onSpeaker else { return }
        print("[AppDelegate] speaker override lost, re-applying")
        _ = applyRequestedAudioRoute(
            route: "speaker",
            isVideo: currentCallIsVideo,
            force: true
        )
    }

    private func scheduleDeferredRouteCheck(after delay: TimeInterval) {
        deferredRouteCheck?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self = self,
                  self.routeObserverToken != nil,
                  !self.isApplyingAudioRoute else { return }
            self.evaluateBluetoothAvailability()
            self.reassertSpeakerOverrideIfNeeded()
            self.pushAudioState()
        }
        deferredRouteCheck = work
        DispatchQueue.main.asyncAfter(
            deadline: .now() + max(0.2, delay),
            execute: work
        )
    }

    private func rememberBluetoothPort(_ port: AVAudioSessionPortDescription?) {
        guard let port = port else { return }
        bluetoothSeenInCall = true
        if !port.portName.isEmpty {
            bluetoothKnownName = port.portName
        }
    }

    private func startAudioRouteMonitoring() {
        guard routeObserverToken == nil else { return }

        userSelectedRoute = false
        lastAppliedRoute = nil
        lastAppliedAt = nil

        routeObserverToken = NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleAudioRouteChange(notification)
        }
    }

    private func stopAudioRouteMonitoring() {
        if let token = routeObserverToken {
            NotificationCenter.default.removeObserver(token)
            routeObserverToken = nil
        }
        deferredRouteCheck?.cancel()
        deferredRouteCheck = nil
    }

    private func pushAudioState() {
        guard let channel = audioRouteChannel else { return }
        channel.invokeMethod("onAudioRouteChanged", arguments: readAudioState())
    }

    private func handleAudioRouteChange(_ notification: Notification) {
        guard routeObserverToken != nil else { return }
        guard !isApplyingAudioRoute else {
            scheduleDeferredRouteCheck(after: 0.5)
            return
        }
        if let until = routeChangeQuietUntil, Date() < until {
            scheduleDeferredRouteCheck(after: until.timeIntervalSinceNow + 0.2)
            return
        }

        guard
            let raw = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue: raw)
        else {
            pushAudioState()
            return
        }

        let session = AVAudioSession.sharedInstance()
        let inputs = session.availableInputs ?? []

        switch reason {
        case .newDeviceAvailable, .categoryChange, .routeConfigurationChange:
            evaluateBluetoothAvailability()

        case .oldDeviceUnavailable:
            let stillConnected = bluetoothPort(in: inputs) != nil ||
                bluetoothPort(in: Array(session.currentRoute.outputs)) != nil

            if !stillConnected && !isBluetoothSuppressed() {
                bluetoothSeenInCall = false
                bluetoothKnownName = nil
            }

            if manualAudioRoute == "bluetooth" {
                let fallback = currentCallIsVideo ? "speaker" : "earpiece"
                manualAudioRoute = fallback
                userSelectedRoute = false
                _ = applyRequestedAudioRoute(
                    route: fallback,
                    isVideo: currentCallIsVideo
                )
            }

        default:
            break
        }

        reassertSpeakerOverrideIfNeeded()
        pushAudioState()
    }

    private func shouldAutoSelectBluetooth() -> Bool {
        if userSelectedRoute { return false }
        guard let current = manualAudioRoute else { return false }
        if current == "bluetooth" { return false }
        return current == "earpiece" || current == "speaker"
    }

    private func applyRequestedAudioRoute(
        route: String,
        isVideo: Bool,
        userInitiated: Bool = false,
        force: Bool = false
    ) -> [String: Any] {
        if userInitiated {
            userSelectedRoute = true
        }

        if !force,
           !userInitiated,
           route == lastAppliedRoute,
           let appliedAt = lastAppliedAt,
           Date().timeIntervalSince(appliedAt) < duplicateApplyWindow {
            return readAudioState()
        }

        manualAudioRoute = route
        currentCallIsVideo = isVideo
        lastAppliedRoute = route
        lastAppliedAt = Date()
        isApplyingAudioRoute = true
        routeChangeQuietUntil = Date().addingTimeInterval(routeChangeQuietWindow)
        defer {
            isApplyingAudioRoute = false
        }

        let rtcSession = RTCAudioSession.sharedInstance()
        let session = AVAudioSession.sharedInstance()

        let options = categoryOptions(forRoute: route, isVideo: isVideo)
        let categoryKey = [
            isVideo ? "video" : "voice",
            options.contains(.allowBluetooth) ? "bt" : "nobt",
            options.contains(.defaultToSpeaker) ? "speaker" : "plain"
        ].joined(separator: "-")

        if force || categoryKey != lastCategoryKey {
            let config = RTCAudioSessionConfiguration.webRTC()
            config.category = AVAudioSession.Category.playAndRecord.rawValue
            config.mode = isVideo
                ? AVAudioSession.Mode.videoChat.rawValue
                : AVAudioSession.Mode.voiceChat.rawValue
            config.categoryOptions = options
            RTCAudioSessionConfiguration.setWebRTC(config)

            rtcSession.lockForConfiguration()
            defer { rtcSession.unlockForConfiguration() }

            do {
                try rtcSession.setConfiguration(config)
                lastCategoryKey = categoryKey
            } catch {
                print("[AppDelegate] setConfiguration(\(route)) error: \(error.localizedDescription)")
            }
        }

        let inputs = session.availableInputs ?? []
        let builtInMic = inputs.first { $0.portType == .builtInMic }
        let bluetoothPort = inputs.first {
            $0.portType == .bluetoothHFP ||
                $0.portType == .bluetoothLE ||
                $0.portType == .carAudio
        }
        let wiredPort = inputs.first {
            $0.portType == .headsetMic || $0.portType == .usbAudio
        }

        switch route {
        case "speaker":
            try? rtcSession.overrideOutputAudioPort(.none)
            try? rtcSession.overrideOutputAudioPort(.speaker)
            if let builtInMic {
                try? session.setPreferredInput(builtInMic)
            } else {
                try? session.setPreferredInput(nil)
            }
            let outputs = session.currentRoute.outputs.map { $0.portType.rawValue }
            print("[AppDelegate] speaker route applied outputs=\(outputs)")

        case "bluetooth":
            try? rtcSession.overrideOutputAudioPort(.none)
            if let port = bluetoothPort {
                try? rtcSession.setPreferredInput(port)
                rememberBluetoothPort(port)
            } else {
                bluetoothSeenInCall = false
                bluetoothKnownName = nil
                try? session.setPreferredInput(nil)
            }

        case "headset":
            try? rtcSession.overrideOutputAudioPort(.none)
            if let port = wiredPort {
                try? rtcSession.setPreferredInput(port)
            }

        default:
            try? rtcSession.overrideOutputAudioPort(.none)
            try? session.setPreferredInput(builtInMic)
        }

        return readAudioState()
    }

    private func clearPreferredInputSelection() {
        let rtcSession = RTCAudioSession.sharedInstance()
        rtcSession.lockForConfiguration()
        defer { rtcSession.unlockForConfiguration() }
        try? AVAudioSession.sharedInstance().setPreferredInput(nil)
        try? rtcSession.overrideOutputAudioPort(.none)
    }

    private func readAudioState() -> [String: Any] {
        let session = AVAudioSession.sharedInstance()
        let inputs = session.availableInputs ?? []
        let outputs = session.currentRoute.outputs

        var isBt = false
        var btName = bluetoothKnownName ?? "Bluetooth"
        var isWired = false
        var hsName = "Headset"

        for port in inputs + outputs {
            if port.portType == .bluetoothHFP ||
                   port.portType == .bluetoothLE ||
                   port.portType == .bluetoothA2DP ||
                   port.portType == .carAudio {
                isBt = true
                if !port.portName.isEmpty {
                    btName = port.portName
                    bluetoothKnownName = port.portName
                }
            } else if port.portType == .headsetMic ||
                          port.portType == .headphones ||
                          port.portType == .usbAudio {
                isWired = true
                if !port.portName.isEmpty && hsName == "Headset" {
                    hsName = port.portName
                }
            }
        }

        if isBt {
            bluetoothSeenInCall = true
        } else if bluetoothSeenInCall && isBluetoothSuppressed() {
            isBt = true
            if let known = bluetoothKnownName, !known.isEmpty {
                btName = known
            }
        }

        var activeOutput = "earpiece"
        if let out = outputs.first {
            switch out.portType {
            case .builtInSpeaker:
                activeOutput = "speaker"
            case .bluetoothHFP, .bluetoothA2DP, .bluetoothLE, .carAudio:
                activeOutput = "bluetooth"
            case .headphones, .headsetMic, .usbAudio:
                activeOutput = "headset"
            default:
                activeOutput = "earpiece"
            }
        }

        return [
            "isBluetoothConnected": isBt,
            "bluetoothName": btName,
            "isHeadsetConnected": isWired,
            "headsetName": hsName,
            "activeOutput": activeOutput
        ]
    }

    private func applyInitialOutputPort(isVideo: Bool) {
        let session = AVAudioSession.sharedInstance()
        let inputs = session.availableInputs ?? []

        if let port = bluetoothPort(in: inputs) {
            rememberBluetoothPort(port)
            manualAudioRoute = "bluetooth"
            _ = applyRequestedAudioRoute(
                route: "bluetooth",
                isVideo: isVideo
            )
            return
        }

        let wiredPort = inputs.first {
            $0.portType == .headsetMic || $0.portType == .usbAudio
        }

        if wiredPort != nil {
            manualAudioRoute = "headset"
            _ = applyRequestedAudioRoute(
                route: "headset",
                isVideo: isVideo
            )
            return
        }

        let fallback = isVideo ? "speaker" : "earpiece"
        manualAudioRoute = fallback
        _ = applyRequestedAudioRoute(
            route: fallback,
            isVideo: isVideo
        )
    }

    private func prepareCallKitManualAudio(isVideo: Bool) {
        configureDefaultWebRTCAudio(isVideo: isVideo)
        let rtcAudio = RTCAudioSession.sharedInstance()
        rtcAudio.useManualAudio = true
        rtcAudio.isAudioEnabled = false
    }

    private func releaseCallKitManualAudio() {
        stopAudioRouteMonitoring()
        isApplyingAudioRoute = false
        routeChangeQuietUntil = nil
        userSelectedRoute = false
        lastAppliedRoute = nil
        lastAppliedAt = nil
        lastCategoryKey = nil
        manualAudioRoute = nil
        currentCallIsVideo = false
        bluetoothKnownName = nil
        bluetoothSeenInCall = false
        clearPreferredInputSelection()
        configureDefaultWebRTCAudio(isVideo: false)
        let rtcAudio = RTCAudioSession.sharedInstance()
        rtcAudio.isAudioEnabled = false
        rtcAudio.useManualAudio = false
    }

    private func updateCallingStatusViaApi(
        callId: String,
        remoteUserId: Int,
        callingStatus: String,
        endpointIndex: Int = 0
    ) {
        guard !callId.isEmpty, callId != "null" else {
            print("[AppDelegate] updateCallingStatusViaApi ABORTED: callId is empty")
            return
        }

        if endpointIndex == 0 {
            if handledRingingCallIds.contains(callId) {
                return
            }
            handledRingingCallIds.insert(callId)
        }

        guard endpointIndex < callingStatusEndpoints.count else {
            return
        }

        guard let token = Self.readAccessToken(), !token.isEmpty else {
            print("[AppDelegate] updateCallingStatusViaApi ABORTED: token not found")
            handledRingingCallIds.remove(callId)
            return
        }

        let path = callingStatusEndpoints[endpointIndex]
        guard let url = URL(string: "\(apiBaseUrl)\(path)") else {
            return
        }

        let bodyDict: [String: Any] = [
            "callId": callId,
            "remoteUserId": remoteUserId,
            "callingStatus": callingStatus
        ]

        guard let bodyData = try? JSONSerialization.data(withJSONObject: bodyDict, options: []) else {
            return
        }

        var req = URLRequest(url: url, timeoutInterval: 10)
        req.httpMethod = "POST"
        req.httpBody = bodyData
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let taskKey = UUID()
        let bgId = UIApplication.shared.beginBackgroundTask(withName: "callingStatus.\(callId)") { [weak self] in
            self?.finishBackgroundTask(for: taskKey)
        }
        activeBgTasks[taskKey] = bgId

        URLSession.shared.dataTask(with: req) { [weak self] data, response, error in
            if let error = error {
                print("[AppDelegate] updateCallingStatusViaApi error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.handledRingingCallIds.remove(callId)
                    self?.finishBackgroundTask(for: taskKey)
                }
                return
            }

            if let http = response as? HTTPURLResponse {
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                print("[AppDelegate] updateCallingStatusViaApi \(path) HTTP status=\(http.statusCode) body=\(body)")
                if http.statusCode == 404 && endpointIndex + 1 < callingStatusEndpoints.count {
                    DispatchQueue.main.async {
                        self?.finishBackgroundTask(for: taskKey)
                        self?.updateCallingStatusViaApi(
                            callId: callId,
                            remoteUserId: remoteUserId,
                            callingStatus: callingStatus,
                            endpointIndex: endpointIndex + 1
                        )
                    }
                    return
                }
            }

            DispatchQueue.main.async {
                self?.finishBackgroundTask(for: taskKey)
            }
        }.resume()
    }

    private func rejectCallViaApi(callId: String, groupId: String?) {
        guard !callId.isEmpty, callId != "null" else {
            print("[AppDelegate] rejectCallViaApi ABORTED: callId is empty")
            return
        }

        if handledDeclineCallIds.contains(callId) {
            print("[AppDelegate] rejectCallViaApi skipped duplicate callId=\(callId)")
            return
        }
        handledDeclineCallIds.insert(callId)

        guard let token = Self.readAccessToken(), !token.isEmpty else {
            print("[AppDelegate] rejectCallViaApi ABORTED: no access token found in UserDefaults")
            handledDeclineCallIds.remove(callId)
            return
        }

        var comps = URLComponents(string: "\(apiBaseUrl)/callRejected")
        var items = [URLQueryItem(name: "callId", value: callId)]
        if let g = groupId, !g.isEmpty, g != "null" {
            items.append(URLQueryItem(name: "groupId", value: g))
        }
        comps?.queryItems = items

        guard let url = comps?.url else {
            print("[AppDelegate] rejectCallViaApi ABORTED: malformed URL")
            handledDeclineCallIds.remove(callId)
            return
        }

        var req = URLRequest(url: url, timeoutInterval: 10)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let taskKey = UUID()
        let bgId = UIApplication.shared.beginBackgroundTask(withName: "rejectCall.\(callId)") { [weak self] in
            self?.finishBackgroundTask(for: taskKey)
        }
        activeBgTasks[taskKey] = bgId

        URLSession.shared.dataTask(with: req) { [weak self] data, response, error in
            if let error = error {
                print("[AppDelegate] rejectCallViaApi error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.handledDeclineCallIds.remove(callId)
                }
            } else if let http = response as? HTTPURLResponse {
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                print("[AppDelegate] rejectCallViaApi HTTP status=\(http.statusCode) body=\(body)")
            }
            DispatchQueue.main.async {
                self?.finishBackgroundTask(for: taskKey)
            }
        }.resume()
    }

    private func finishBackgroundTask(for key: UUID) {
        if let bgId = activeBgTasks.removeValue(forKey: key), bgId != .invalid {
            UIApplication.shared.endBackgroundTask(bgId)
        }
    }

    private func handleRecentsCallback(_ activity: NSUserActivity) -> Bool {
        guard let interaction = activity.interaction else { return false }
        var personHandle: String?
        var isVideo = false
        if let intent = interaction.intent as? INStartVideoCallIntent {
            personHandle = intent.contacts?.first?.personHandle?.value
            isVideo = true
        } else if let intent = interaction.intent as? INStartAudioCallIntent {
            personHandle = intent.contacts?.first?.personHandle?.value
            isVideo = false
        } else if #available(iOS 13.0, *), let intent = interaction.intent as? INStartCallIntent {
            personHandle = intent.contacts?.first?.personHandle?.value
            isVideo = intent.callCapability == .videoCall
        }
        guard let handle = personHandle, !handle.isEmpty else { return false }
        print("[AppDelegate] recents callback handle=\(handle) isVideo=\(isVideo)")
        sendRecentsCallback(handle: handle, isVideo: isVideo)
        return true
    }

    private func sendRecentsCallback(handle: String, isVideo: Bool) {
        pendingRecentsCallback = [
            "handle": handle,
            "isVideo": isVideo,
            "issuedAt": Int(Date().timeIntervalSince1970)
        ]
        flushRecentsCallback()
    }

    private func flushRecentsCallback() {
        guard let payload = pendingRecentsCallback else { return }
        guard let controller = window?.rootViewController as? FlutterViewController else { return }
        let channel = FlutterMethodChannel(
            name: "com.fgtracker.callkit_events",
            binaryMessenger: controller.binaryMessenger
        )
        channel.invokeMethod("recentsCallback", arguments: payload) { [weak self] result in
            if result is FlutterError { return }
            self?.pendingRecentsCallback = nil
            print("[AppDelegate] recents callback delivered to Dart")
        }
    }

    private static func readAccessToken() -> String? {
        let defaults = UserDefaults.standard
        for key in candidateTokenPrefKeys {
            if let val = defaults.string(forKey: key), !val.isEmpty {
                return val
            }
        }
        return nil
    }

    private static func stringValue(_ raw: Any?) -> String? {
        guard let raw = raw else { return nil }
        let str = "\(raw)".trimmingCharacters(in: .whitespacesAndNewlines)
        return (str.isEmpty || str == "<null>" || str == "null") ? nil : str
    }

    private static func ensureValidUuid(_ raw: String?) -> String {
        guard let raw = raw, !raw.isEmpty else {
            return UUID().uuidString.lowercased()
        }
        if UUID(uuidString: raw) != nil {
            return raw.lowercased()
        }
        var bytes = Array(SHA256.hash(data: Foundation.Data(raw.utf8)).prefix(16))
        bytes[6] = (bytes[6] & 0x0f) | 0x50
        bytes[8] = (bytes[8] & 0x3f) | 0x80
        let hex = bytes.map { String(format: "%02x", $0) }.joined()
        let p1 = hex.prefix(8)
        let p2 = hex.dropFirst(8).prefix(4)
        let p3 = hex.dropFirst(12).prefix(4)
        let p4 = hex.dropFirst(16).prefix(4)
        let p5 = hex.dropFirst(20).prefix(12)
        return "\(p1)-\(p2)-\(p3)-\(p4)-\(p5)"
    }

    private static func parseIsVideo(_ p: [AnyHashable: Any]) -> Bool {
        if let boolVal = p["isVideo"] as? Bool { return boolVal }
        if let strVideo = stringValue(p["isVideo"])?.lowercased(),
           strVideo == "true" || strVideo == "1" {
            return true
        }
        for key in ["type", "call_type", "callType"] {
            if let num = p[key] as? NSNumber {
                return num.intValue == 1
            }
            if let str = stringValue(p[key])?.lowercased(),
               str == "1" || str == "video" {
                return true
            }
        }
        return false
    }
}
