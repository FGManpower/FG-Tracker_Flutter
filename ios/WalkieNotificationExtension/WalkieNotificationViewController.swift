import UIKit
import UserNotifications
import UserNotificationsUI

class WalkieNotificationViewController: UIViewController, UNNotificationContentExtension {

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 247/255, green: 248/255, blue: 255/255, alpha: 1.0)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1.2
        view.layer.borderColor = UIColor(red: 220/255, green: 225/255, blue: 245/255, alpha: 1.0).cgColor
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let liveBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 235/255, green: 40/255, blue: 40/255, alpha: 1.0)
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let liveDot: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let liveLabel: UILabel = {
        let label = UILabel()
        label.text = "LIVE"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let joinedLabel: UILabel = {
        let label = UILabel()
        label.text = "👥 Active"
        label.textColor = UIColor(red: 101/255, green: 105/255, blue: 133/255, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        if let bundlePath = Bundle(for: WalkieNotificationViewController.self).path(forResource: "ic_walkie_device", ofType: "png"),
           let image = UIImage(contentsOfFile: bundlePath) {
            iv.image = image
        } else if #available(iOS 14.0, *) {
            iv.image = UIImage(systemName: "dot.radiowaves.left.and.right")
        } else {
            iv.image = UIImage(systemName: "antenna.radiowaves.left.and.right")
        }
        iv.tintColor = UIColor(red: 76/255, green: 79/255, blue: 232/255, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let groupTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Field Team"
        label.textColor = UIColor(red: 20/255, green: 23/255, blue: 56/255, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let speakerSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Someone is speaking..."
        label.textColor = UIColor(red: 76/255, green: 79/255, blue: 232/255, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("✕  Cancel", for: .normal)
        btn.setTitleColor(UIColor(red: 20/255, green: 23/255, blue: 56/255, alpha: 1.0), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = UIColor(red: 220/255, green: 225/255, blue: 245/255, alpha: 1.0).cgColor
        btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        btn.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var acceptButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("✓  Accept", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        btn.backgroundColor = UIColor(red: 76/255, green: 79/255, blue: 232/255, alpha: 1.0)
        btn.layer.cornerRadius = 16
        btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        btn.addTarget(self, action: #selector(handleAccept), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startPulsingLiveDot()
    }

    private func setupUI() {
        view.backgroundColor = .clear
        view.addSubview(cardView)

        cardView.addSubview(liveBadge)
        liveBadge.addSubview(liveDot)
        liveBadge.addSubview(liveLabel)

        cardView.addSubview(joinedLabel)
        cardView.addSubview(iconImageView)
        cardView.addSubview(groupTitleLabel)
        cardView.addSubview(speakerSubtitleLabel)
        cardView.addSubview(cancelButton)
        cardView.addSubview(acceptButton)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),

            // Top row: Live badge
            liveBadge.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            liveBadge.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            liveBadge.heightAnchor.constraint(equalToConstant: 20),

            liveDot.leadingAnchor.constraint(equalTo: liveBadge.leadingAnchor, constant: 8),
            liveDot.centerYAnchor.constraint(equalTo: liveBadge.centerYAnchor),
            liveDot.widthAnchor.constraint(equalToConstant: 6),
            liveDot.heightAnchor.constraint(equalToConstant: 6),

            liveLabel.leadingAnchor.constraint(equalTo: liveDot.trailingAnchor, constant: 5),
            liveLabel.trailingAnchor.constraint(equalTo: liveBadge.trailingAnchor, constant: -8),
            liveLabel.centerYAnchor.constraint(equalTo: liveBadge.centerYAnchor),

            // Top row: Joined label
            joinedLabel.centerYAnchor.constraint(equalTo: liveBadge.centerYAnchor),
            joinedLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            // Middle row: Icon
            iconImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            iconImageView.topAnchor.constraint(equalTo: liveBadge.bottomAnchor, constant: 10),
            iconImageView.widthAnchor.constraint(equalToConstant: 48),
            iconImageView.heightAnchor.constraint(equalToConstant: 48),

            // Middle row: Group Title & Speaker
            groupTitleLabel.topAnchor.constraint(equalTo: iconImageView.topAnchor, constant: 2),
            groupTitleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            groupTitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            speakerSubtitleLabel.topAnchor.constraint(equalTo: groupTitleLabel.bottomAnchor, constant: 4),
            speakerSubtitleLabel.leadingAnchor.constraint(equalTo: groupTitleLabel.leadingAnchor),
            speakerSubtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            // Bottom row: Action buttons
            acceptButton.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
            acceptButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            acceptButton.heightAnchor.constraint(equalToConstant: 34),
            acceptButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            cancelButton.centerYAnchor.constraint(equalTo: acceptButton.centerYAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: acceptButton.leadingAnchor, constant: -10),
            cancelButton.heightAnchor.constraint(equalToConstant: 34),
        ])
    }

    private func startPulsingLiveDot() {
        UIView.animate(withDuration: 0.8, delay: 0.0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
            self.liveDot.alpha = 0.25
        }, completion: nil)
    }

    func didReceive(_ notification: UNNotification) {
        var groupName: String?
        var speakerName: String?
        var count: String?

        let userInfo = notification.request.content.userInfo

        // 1. Direct userInfo
        groupName = (userInfo["groupName"] as? String) ?? (userInfo["title"] as? String)
        speakerName = (userInfo["speakerName"] as? String) ?? (userInfo["speaker"] as? String)
        count = (userInfo["joinedMemberCount"] as? String) ?? (userInfo["joinedCount"] as? String)

        // 2. Inside payload string (from flutter_local_notifications)
        if let payloadStr = userInfo["payload"] as? String,
           let payloadData = payloadStr.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any] {
            if groupName == nil || groupName!.isEmpty {
                groupName = json["groupName"] as? String
            }
            if speakerName == nil || speakerName!.isEmpty {
                speakerName = json["speakerName"] as? String
            }
            if count == nil || count!.isEmpty {
                count = (json["joinedMemberCount"] as? String) ?? (json["joinedCount"] as? String)
            }
        }

        // 3. Inside data dictionary (FCM push notification)
        if let dataDict = userInfo["data"] as? [String: Any] {
            if groupName == nil || groupName!.isEmpty {
                groupName = dataDict["groupName"] as? String
            }
            if speakerName == nil || speakerName!.isEmpty {
                speakerName = dataDict["speakerName"] as? String
            }
            if count == nil || count!.isEmpty {
                count = (dataDict["joinedMemberCount"] as? String) ?? (dataDict["joinedCount"] as? String)
            }
        }

        // Fallbacks
        let finalTitle = (groupName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
            ? groupName!
            : (notification.request.content.title.isEmpty ? "Field Team" : notification.request.content.title)

        let finalSpeaker = (speakerName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
            ? speakerName!
            : "Someone"

        groupTitleLabel.text = finalTitle
        speakerSubtitleLabel.text = "\(finalSpeaker) is speaking..."

        if let c = count, !c.isEmpty && c != "0" {
            joinedLabel.text = "👥 \(c) Joined"
        } else {
            joinedLabel.text = "👥 Active"
        }
    }

    @objc private func handleAccept() {
        extensionContext?.performNotificationDefaultAction()
    }

    @objc private func handleCancel() {
        extensionContext?.dismissNotificationContentExtension()
    }

    func didReceive(_ response: UNNotificationResponse, completionHandler: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        if response.actionIdentifier == "WALKIE_ACCEPT" {
            completionHandler(.dismissAndForwardAction)
        } else {
            completionHandler(.dismiss)
        }
    }
}
