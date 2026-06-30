import UIKit
import Flutter
import Firebase
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        GMSServices.provideAPIKey("")
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let flutterViewController = window?.rootViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(name: "com.yourapp.notifications", binaryMessenger: flutterViewController.binaryMessenger)
            channel.invokeMethod("handleDeepLink", arguments: url.absoluteString)
        }
        return true
    }

    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let url = userActivity.webpageURL {
            if let flutterViewController = window?.rootViewController as? FlutterViewController {
                let channel = FlutterMethodChannel(name: "com.yourapp.notifications", binaryMessenger: flutterViewController.binaryMessenger)
                channel.invokeMethod("handleDeepLink", arguments: url.absoluteString)
            }
        }
        return true
    }
}
