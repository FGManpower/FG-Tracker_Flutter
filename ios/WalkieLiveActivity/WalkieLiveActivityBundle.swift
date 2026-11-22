import WidgetKit
import SwiftUI

@main
struct WalkieLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        if #available(iOS 16.1, *) {
            WalkieLiveActivity()
        }
    }
}

