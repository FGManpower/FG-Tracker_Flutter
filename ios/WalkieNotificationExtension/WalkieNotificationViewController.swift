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
        if #available(iOS 14.0, *) {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),

            // Live badge
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

            // Joined label
            joinedLabel.centerYAnchor.constraint(equalTo: liveBadge.centerYAnchor),
            joinedLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            // Icon
            iconImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            iconImageView.topAnchor.constraint(equalTo: liveBadge.bottomAnchor, constant: 12),
            iconImageView.widthAnchor.constraint(equalToConstant: 44),
            iconImageView.heightAnchor.constraint(equalToConstant: 44),
            iconImageView.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -14),

            // Titles
            groupTitleLabel.topAnchor.constraint(equalTo: iconImageView.topAnchor, constant: 2),
            groupTitleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            groupTitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            speakerSubtitleLabel.topAnchor.constraint(equalTo: groupTitleLabel.bottomAnchor, constant: 4),
            speakerSubtitleLabel.leadingAnchor.constraint(equalTo: groupTitleLabel.leadingAnchor),
            speakerSubtitleLabel.trailingAnchor.constraint(equalTo: groupTitleLabel.trailingAnchor),
        ])
    }

    func didReceive(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo

        let groupName = (userInfo["groupName"] as? String) ??
                        (userInfo["title"] as? String) ??
                        notification.request.content.title
        let speakerName = (userInfo["speakerName"] as? String) ??
                          (userInfo["speaker"] as? String) ??
                          "Someone"
        let count = (userInfo["joinedMemberCount"] as? String) ??
                    (userInfo["joinedCount"] as? String) ?? ""

        groupTitleLabel.text = groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Field Team" : groupName
        speakerSubtitleLabel.text = "\(speakerName) is speaking..."

        if !count.isEmpty && count != "0" {
            joinedLabel.text = "👥 \(count) Joined"
        } else {
            joinedLabel.text = "👥 Active"
        }
    }

    func didReceive(_ response: UNNotificationResponse, completionHandler: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        if response.actionIdentifier == "WALKIE_ACCEPT" {
            completionHandler(.open)
        } else {
            completionHandler(.dismiss)
        }
    }
}
