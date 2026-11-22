import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
struct WalkieLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WalkieLiveActivityAttributes.self) { context in
            // MARK: - Lock Screen & Banner Presentation (Zomato / Domino's Style Card)
            WalkieLockScreenView(context: context)
                .activityBackgroundTint(Color(red: 20/255, green: 23/255, blue: 56/255))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            // MARK: - Dynamic Island Presentation (iPhone 14 Pro, 15, 16+)
            DynamicIsland {
                // Expanded Leading
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: "dot.radiowaves.left.and.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 128/255, green: 128/255, blue: 238/255))
                        Text("LIVE")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .cornerRadius(6)
                    }
                    .padding(.leading, 4)
                }

                // Expanded Trailing
                DynamicIslandExpandedRegion(.trailing) {
                    HStack(spacing: 4) {
                        Text(context.state.joinedCount > 0 ? "👥 \(context.state.joinedCount)" : "👥 Active")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(red: 160/255, green: 165/255, blue: 195/255))
                    }
                    .padding(.trailing, 4)
                }

                // Expanded Center
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.attributes.groupName.isEmpty ? "Walkie-Talkie" : context.attributes.groupName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text("\(context.state.speakerName) is speaking...")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 128/255, green: 128/255, blue: 238/255))
                            .lineLimit(1)
                    }
                }

                // Expanded Bottom
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 12) {
                        Link(destination: URL(string: "fgtracker://walkie?groupId=\(context.attributes.groupId)&action=cancel")!) {
                            HStack(spacing: 4) {
                                Text("✕  Cancel")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(16)
                        }

                        Link(destination: URL(string: "fgtracker://walkie?groupId=\(context.attributes.groupId)&action=accept")!) {
                            HStack(spacing: 4) {
                                Text("✓  Accept")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .background(Color(red: 83/255, green: 56/255, blue: 238/255))
                            .cornerRadius(16)
                        }
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                // Compact Left Island
                HStack(spacing: 3) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(red: 128/255, green: 128/255, blue: 238/255))
                    Circle()
                        .fill(Color.red)
                        .frame(width: 5, height: 5)
                }
            } compactTrailing: {
                // Compact Right Island
                Text(context.state.speakerName.components(separatedBy: " ").first ?? "PTT")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 128/255, green: 128/255, blue: 238/255))
                    .lineLimit(1)
            } minimal: {
                // Minimal Island Icon
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 128/255, green: 128/255, blue: 238/255))
            }
        }
    }
}

// MARK: - Lock Screen & Notification Center Custom SwiftUI Card View
@available(iOS 16.1, *)
struct WalkieLockScreenView: View {
    let context: ActivityViewContext<WalkieLiveActivityAttributes>

    var body: some View {
        VStack(spacing: 12) {
            // Top Row: LIVE Badge, Group Name, Joined Member Count
            HStack(alignment: .center) {
                // Red LIVE pill
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 6, height: 6)
                    Text("LIVE")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.red)
                .cornerRadius(10)

                Spacer()

                // Group Name
                Text(context.attributes.groupName.isEmpty ? "Field Team" : context.attributes.groupName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Spacer()

                // Joined Badge
                HStack(spacing: 4) {
                    Text(context.state.joinedCount > 0 ? "👥 \(context.state.joinedCount) Joined" : "👥 Active")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 180/255, green: 185/255, blue: 220/255))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
            }

            // Middle Row: Speaker Avatar / Device Icon, Speaker Name, Audio Waves
            HStack(spacing: 12) {
                // Walkie-Talkie Icon / Avatar
                ZStack {
                    Circle()
                        .fill(Color(red: 83/255, green: 56/255, blue: 238/255).opacity(0.3))
                        .frame(width: 44, height: 44)
                    Image(systemName: "dot.radiowaves.left.and.right")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 128/255, green: 128/255, blue: 238/255))
                }

                // Speaker details
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(context.state.speakerName) is speaking...")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 128/255, green: 128/255, blue: 238/255))
                        .lineLimit(1)
                    Text("Tap Accept to join live channel floor")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)
                }

                Spacer()

                // Live Audio Wave Bars
                HStack(spacing: 3) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(red: 83/255, green: 56/255, blue: 238/255))
                        .frame(width: 3, height: 16)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(red: 128/255, green: 128/255, blue: 238/255))
                        .frame(width: 3, height: 24)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(red: 83/255, green: 56/255, blue: 238/255))
                        .frame(width: 3, height: 12)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(red: 128/255, green: 128/255, blue: 238/255))
                        .frame(width: 3, height: 20)
                }
            }

            // Bottom Row: Action Buttons (✕ Cancel and ✓ Accept)
            HStack(spacing: 12) {
                Link(destination: URL(string: "fgtracker://walkie?groupId=\(context.attributes.groupId)&action=cancel")!) {
                    HStack(spacing: 6) {
                        Text("✕  Cancel")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(18)
                }

                Link(destination: URL(string: "fgtracker://walkie?groupId=\(context.attributes.groupId)&action=accept")!) {
                    HStack(spacing: 6) {
                        Text("✓  Accept")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(Color(red: 83/255, green: 56/255, blue: 238/255))
                    .cornerRadius(18)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 20/255, green: 23/255, blue: 56/255))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(red: 83/255, green: 56/255, blue: 238/255).opacity(0.4), lineWidth: 1.2)
                )
        )
    }
}

