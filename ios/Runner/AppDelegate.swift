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
import CryptoKit
import flutter_callkit_incoming


private let apiBaseUrl = "http://fgtracker.in:3000/api"
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


    private var hasLaunchedIntoForeground = false
    private var enteredBackgroundAt: Date?
    private let socketSuspensionThresholdSeconds: TimeInterval = 25.0

    private var activeBgTasks: [UUID: UIBackgroundTaskIdentifier] = [:]
    private var handledDeclineCallIds = Set<String>()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        GMSServices.provideAPIKey("AIzaSyAgt-V8kmcQJb_6Cj6LHArWfhWjVPh7N_Q")   // replace with your iOS Google Maps key
        GeneratedPluginRegistrant.register(with: self)


        let mainQueue = DispatchQueue.main
        let registry = PKPushRegistry(queue: mainQueue)
        registry.delegate = self
        registry.desiredPushTypes = [PKPushType.voIP]
        self.voipRegistry = registry


        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }


    override func applicationDidBecomeActive(_ application: UIApplication) {
        hasLaunchedIntoForeground = true
        enteredBackgroundAt = nil
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

    private var isDartSocketAlive: Bool {
        guard hasLaunchedIntoForeground else { return false }
        if let bgTime = enteredBackgroundAt,
           Date().timeIntervalSince(bgTime) >= socketSuspensionThresholdSeconds {
            return false
        }
        return true
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
            completion()
            return
        }

        let p = payload.dictionaryPayload

        let rawId = Self.stringValue(p["id"])
            ?? Self.stringValue(p["sessionId"])
            ?? Self.stringValue(p["session_id"])
        let id = Self.ensureValidUuid(rawId)

        let signal = Self.stringValue(p["signal_type"])
            ?? Self.stringValue(p["type_signal"])
            ?? Self.stringValue(p["action"])
            ?? "startCall"

        let name = Self.stringValue(p["nameCaller"])
            ?? Self.stringValue(p["callerName"])
            ?? Self.stringValue(p["caller_name"])
            ?? "Unknown"

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
        for key in ["callId", "call_id", "groupId", "group_id", "sessionId", "session_id", "callerId"] {
            if extraDict[key] == nil, let topVal = p[key] {
                extraDict[key] = topVal
            }
        }
        if extraDict["sessionId"] == nil {
            extraDict["sessionId"] = id
        }

        let endSignals: Set<String> = ["endCall", "callEnded", "cancelCall", "callRejected", "missedCall"]
        if endSignals.contains(signal) {
            let dummy = flutter_callkit_incoming.Data(
                id: UUID().uuidString,
                nameCaller: name,
                handle: name,
                type: 0
            )
            SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(
                dummy,
                fromPushKit: true
            ) {
                SwiftFlutterCallkitIncomingPlugin.sharedInstance?.endCall(dummy)
                let real = flutter_callkit_incoming.Data(
                    id: id,
                    nameCaller: name,
                    handle: name,
                    type: isVideo ? 1 : 0
                )
                SwiftFlutterCallkitIncomingPlugin.sharedInstance?.endCall(real)
                completion()
            }
        } else {
            let data = flutter_callkit_incoming.Data(
                id: id,
                nameCaller: name,
                handle: name,
                type: isVideo ? 1 : 0
            )
            data.appName = "FG Tracker"
            if !avatar.isEmpty {
                data.avatar = avatar
            }
            data.extra = NSDictionary(dictionary: extraDict)

            SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(
                data,
                fromPushKit: true
            ) {
                completion()
            }
        }
    }


    func onAccept(_ call: Call, _ action: CXAnswerCallAction) {
        print("[AppDelegate] onAccept")
        action.fulfill()
    }

    func onDecline(_ call: Call, _ action: CXEndCallAction) {
        let extra = call.data.extra as? [String: Any] ?? [:]
        let callId = Self.stringValue(extra["callId"])
            ?? Self.stringValue(extra["call_id"])
            ?? ""
        let groupId = Self.stringValue(extra["groupId"])
            ?? Self.stringValue(extra["group_id"])

        print("[AppDelegate] onDecline callId=\(callId) groupId=\(groupId ?? "nil") isDartSocketAlive=\(isDartSocketAlive)")

        if isDartSocketAlive {
            print("[AppDelegate] Skipping native REST decline — Dart socket path is active")
            action.fulfill()
            return
        }

        rejectCallViaApi(callId: callId, groupId: groupId)
        action.fulfill()
    }

    func onEnd(_ call: Call, _ action: CXEndCallAction) {
        print("[AppDelegate] onEnd")
        action.fulfill()
    }

    func onTimeOut(_ call: Call) {
        print("[AppDelegate] onTimeOut")
    }

    func didActivateAudioSession(_ audioSession: AVAudioSession) {
        // Uncomment if your WebRTC SDK requires manual CallKit audio session activation:
//        RTCAudioSession.sharedInstance().audioSessionDidActivate(audioSession)
//        RTCAudioSession.sharedInstance().isAudioEnabled = true
    }

    func didDeactivateAudioSession(_ audioSession: AVAudioSession) {
        // Uncomment if your WebRTC SDK requires manual CallKit audio session deactivation:
//        RTCAudioSession.sharedInstance().audioSessionDidDeactivate(audioSession)
//        RTCAudioSession.sharedInstance().isAudioEnabled = false
    }

    func providerDidReset() {
        print("[AppDelegate] providerDidReset")
        handledDeclineCallIds.removeAll()
    }

    // MARK: - Native REST Decline (Terminated / Background-Suspended State Only)
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
