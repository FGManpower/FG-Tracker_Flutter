import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {

    private let secureOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 1.0
        view.isHidden = true
        return view
    }()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GMSServices.provideAPIKey("AIzaSyDu1PPgXuqRdLfEfA9Gf-6A8QydUlyMq-0")
        GeneratedPluginRegistrant.register(with: self)

        #if !DEBUG
        addSecuredView()
        #endif

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func applicationWillResignActive(_ application: UIApplication) {
        secureOverlay.isHidden = false
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        secureOverlay.isHidden = true
    }

    private func addSecuredView() {
        guard let window = UIApplication.shared.windows.first else { return }

        if !window.subviews.contains(secureOverlay) {
            secureOverlay.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(secureOverlay)

            NSLayoutConstraint.activate([
                secureOverlay.topAnchor.constraint(equalTo: window.topAnchor),
                secureOverlay.bottomAnchor.constraint(equalTo: window.bottomAnchor),
                secureOverlay.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                secureOverlay.trailingAnchor.constraint(equalTo: window.trailingAnchor)
            ])
        }
    }
}
