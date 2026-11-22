import Foundation
#if canImport(ActivityKit)
import ActivityKit

@available(iOS 16.1, *)
public struct WalkieLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var speakerName: String
        public var speakerImage: String
        public var joinedCount: Int
        public var isSpeaking: Bool
        public var timestamp: Date

        public init(
            speakerName: String = "Someone",
            speakerImage: String = "",
            joinedCount: Int = 0,
            isSpeaking: Bool = true,
            timestamp: Date = Date()
        ) {
            self.speakerName = speakerName
            self.speakerImage = speakerImage
            self.joinedCount = joinedCount
            self.isSpeaking = isSpeaking
            self.timestamp = timestamp
        }
    }

    public var groupId: String
    public var groupName: String

    public init(groupId: String, groupName: String) {
        self.groupId = groupId
        self.groupName = groupName
    }
}
#endif

