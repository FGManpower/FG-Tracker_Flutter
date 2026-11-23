import Foundation
import Flutter
#if canImport(ActivityKit)
import ActivityKit
#endif

@objc public class WalkieLiveActivityManager: NSObject {
    @objc public static let shared = WalkieLiveActivityManager()

    #if canImport(ActivityKit)
    private var activeActivities: [String: Any] = [:]
    #endif

    private var channel: FlutterMethodChannel?

    @objc public func setup(binaryMessenger: FlutterBinaryMessenger) {
        let chan = FlutterMethodChannel(name: "com.fg.walkie/live_activity", binaryMessenger: binaryMessenger)
        chan.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call: call, result: result)
        }
        self.channel = chan
        print("[WalkieLiveActivityManager] Initialized on com.fg.walkie/live_activity")
    }

    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            switch call.method {
            case "startLiveActivity":
                guard let args = call.arguments as? [String: Any],
                      let groupId = args["groupId"] as? String, !groupId.isEmpty else {
                    result(FlutterError(code: "INVALID_ARGS", message: "groupId required", details: nil))
                    return
                }
                let groupName = (args["groupName"] as? String) ?? "Field Team"
                let speakerName = (args["speakerName"] as? String) ?? "Someone"
                let speakerImage = (args["speakerImage"] as? String) ?? ""
                let joinedCount = (args["joinedCount"] as? Int) ?? 0

                let activityId = startLiveActivity(
                    groupId: groupId,
                    groupName: groupName,
                    speakerName: speakerName,
                    speakerImage: speakerImage,
                    joinedCount: joinedCount
                )
                result(activityId)

            case "updateLiveActivity":
                guard let args = call.arguments as? [String: Any],
                      let groupId = args["groupId"] as? String, !groupId.isEmpty else {
                    result(FlutterError(code: "INVALID_ARGS", message: "groupId required", details: nil))
                    return
                }
                let speakerName = (args["speakerName"] as? String) ?? "Someone"
                let speakerImage = (args["speakerImage"] as? String) ?? ""
                let joinedCount = (args["joinedCount"] as? Int) ?? 0
                let isSpeaking = (args["isSpeaking"] as? Bool) ?? true

                updateLiveActivity(
                    groupId: groupId,
                    speakerName: speakerName,
                    speakerImage: speakerImage,
                    joinedCount: joinedCount,
                    isSpeaking: isSpeaking
                )
                result(true)

            case "stopLiveActivity":
                guard let args = call.arguments as? [String: Any],
                      let groupId = args["groupId"] as? String, !groupId.isEmpty else {
                    stopAllLiveActivities()
                    result(true)
                    return
                }
                stopLiveActivity(groupId: groupId)
                result(true)

            case "stopAllLiveActivities":
                stopAllLiveActivities()
                result(true)

            case "isSupported":
                result(ActivityAuthorizationInfo().areActivitiesEnabled)

            default:
                result(FlutterMethodNotImplemented)
            }
        } else {
            result(false)
        }
        #else
        result(false)
        #endif
    }

    #if canImport(ActivityKit)
    @available(iOS 16.1, *)
    @discardableResult
    public func startLiveActivity(
        groupId: String,
        groupName: String,
        speakerName: String,
        speakerImage: String = "",
        joinedCount: Int = 0
    ) -> String? {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("[WalkieLiveActivityManager] Live Activities are disabled by user or system")
            return nil
        }

        // If activity already exists for this group, update it
        if let existing = activeActivities[groupId] as? Activity<WalkieLiveActivityAttributes> {
            let updatedState = WalkieLiveActivityAttributes.ContentState(
                speakerName: speakerName,
                speakerImage: speakerImage,
                joinedCount: joinedCount,
                isSpeaking: true,
                timestamp: Date()
            )
            Task {
                await existing.update(using: updatedState)
            }
            return existing.id
        }

        let attributes = WalkieLiveActivityAttributes(groupId: groupId, groupName: groupName)
        let initialContentState = WalkieLiveActivityAttributes.ContentState(
            speakerName: speakerName,
            speakerImage: speakerImage,
            joinedCount: joinedCount,
            isSpeaking: true,
            timestamp: Date()
        )

        do {
            let activity = try Activity<WalkieLiveActivityAttributes>.request(
                attributes: attributes,
                contentState: initialContentState,
                pushType: .token
            )
            activeActivities[groupId] = activity
            print("[WalkieLiveActivityManager] Started Live Activity id=\(activity.id) for group=\(groupName)")

            // Observe push token updates for backend remote updates
            Task {
                for await tokenData in activity.pushTokenUpdates {
                    let token = tokenData.map { String(format: "%02x", $0) }.joined()
                    print("[WalkieLiveActivityManager] Activity push token: \(token)")
                    DispatchQueue.main.async { [weak self] in
                        self?.channel?.invokeMethod("onActivityPushToken", arguments: [
                            "groupId": groupId,
                            "token": token
                        ])
                    }
                }
            }

            return activity.id
        } catch {
            print("[WalkieLiveActivityManager] Failed to start Live Activity: \(error.localizedDescription)")
            return nil
        }
    }

    @available(iOS 16.1, *)
    public func updateLiveActivity(
        groupId: String,
        speakerName: String,
        speakerImage: String = "",
        joinedCount: Int = 0,
        isSpeaking: Bool = true
    ) {
        guard let activity = activeActivities[groupId] as? Activity<WalkieLiveActivityAttributes> else { return }
        let updatedState = WalkieLiveActivityAttributes.ContentState(
            speakerName: speakerName,
            speakerImage: speakerImage,
            joinedCount: joinedCount,
            isSpeaking: isSpeaking,
            timestamp: Date()
        )
        Task {
            await activity.update(using: updatedState)
        }
    }

    @available(iOS 16.1, *)
    public func stopLiveActivity(groupId: String) {
        guard let activity = activeActivities.removeValue(forKey: groupId) as? Activity<WalkieLiveActivityAttributes> else { return }
        Task {
            await activity.end(dismissalPolicy: .immediate)
            print("[WalkieLiveActivityManager] Stopped Live Activity for group=\(groupId)")
        }
    }

    @available(iOS 16.1, *)
    public func stopAllLiveActivities() {
        for (_, act) in activeActivities {
            if let activity = act as? Activity<WalkieLiveActivityAttributes> {
                Task {
                    await activity.end(dismissalPolicy: .immediate)
                }
            }
        }
        activeActivities.removeAll()
        print("[WalkieLiveActivityManager] Stopped all Live Activities")
    }
    #endif
}

