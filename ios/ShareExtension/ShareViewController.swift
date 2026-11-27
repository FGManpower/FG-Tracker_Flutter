import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    private let appGroupId = "group.com.fg.fgtracker"
    private let pendingDefaultsKey = "pending_share_payload"
    private let hostShareUrl = URL(string: "fgtracker://share-intake")!

    private var hasStartedExtraction = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.25)

        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        view.addSubview(indicator)

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasStartedExtraction else { return }
        hasStartedExtraction = true
        extractAndOpenHostApp()
    }

    private func extractAndOpenHostApp() {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            finishExtension()
            return
        }

        let group = DispatchGroup()
        let lock = NSLock()

        var sharedTexts: [String] = []
        var sharedUrls: [String] = []
        var copiedFiles: [[String: Any]] = []
        var firstKind: String?
        var hadError = false

        let shareDir = sharedIntakeDirectory()

        for item in extensionItems {
            if let attributedText = item.attributedContentText?.string.trimmingCharacters(in: .whitespacesAndNewlines),
               !attributedText.isEmpty {
                lock.lock()
                if !sharedTexts.contains(attributedText) {
                    sharedTexts.append(attributedText)
                }
                lock.unlock()
            }

            guard let providers = item.attachments else { continue }
            for provider in providers {
                if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) ||
                    provider.hasItemConformingToTypeIdentifier(UTType.video.identifier) {
                    group.enter()
                    loadFileItem(provider: provider, typeIdentifier: UTType.movie.identifier, dir: shareDir, fallbackExt: "mp4", mimeType: "video/mp4") { fileInfo, ok in
                        lock.lock()
                        if let fileInfo = fileInfo {
                            copiedFiles.append(fileInfo)
                            if firstKind == nil { firstKind = "video" }
                        } else if !ok {
                            hadError = true
                        }
                        lock.unlock()
                        group.leave()
                    }
                } else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    group.enter()
                    loadImageItem(provider: provider, dir: shareDir) { fileInfo, ok in
                        lock.lock()
                        if let fileInfo = fileInfo {
                            copiedFiles.append(fileInfo)
                            if firstKind == nil { firstKind = "image" }
                        } else if !ok {
                            hadError = true
                        }
                        lock.unlock()
                        group.leave()
                    }
                } else if provider.hasItemConformingToTypeIdentifier(UTType.audio.identifier) {
                    group.enter()
                    loadFileItem(provider: provider, typeIdentifier: UTType.audio.identifier, dir: shareDir, fallbackExt: "m4a", mimeType: "audio/m4a") { fileInfo, ok in
                        lock.lock()
                        if let fileInfo = fileInfo {
                            copiedFiles.append(fileInfo)
                            if firstKind == nil { firstKind = "audio" }
                        } else if !ok {
                            hadError = true
                        }
                        lock.unlock()
                        group.leave()
                    }
                } else if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                    group.enter()
                    loadFileItem(provider: provider, typeIdentifier: UTType.fileURL.identifier, dir: shareDir, fallbackExt: "dat", mimeType: "application/octet-stream") { fileInfo, ok in
                        lock.lock()
                        if let fileInfo = fileInfo {
                            copiedFiles.append(fileInfo)
                            if firstKind == nil { firstKind = "file" }
                        } else if !ok {
                            hadError = true
                        }
                        lock.unlock()
                        group.leave()
                    }
                } else if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    group.enter()
                    provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { data, _ in
                        lock.lock()
                        if let url = data as? URL {
                            if url.isFileURL {
                                if let info = self.copyLocalFile(url: url, dir: shareDir, fallbackExt: url.pathExtension, mimeType: self.mimeTypeForPath(url.path)) {
                                    copiedFiles.append(info)
                                    if firstKind == nil { firstKind = self.kindFromMime(info["mimeType"] as? String) }
                                } else {
                                    hadError = true
                                }
                            } else {
                                sharedUrls.append(url.absoluteString)
                            }
                        } else if let str = data as? String, !str.isEmpty {
                            sharedUrls.append(str)
                        }
                        lock.unlock()
                        group.leave()
                    }
                } else if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    group.enter()
                    provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { data, _ in
                        lock.lock()
                        if let text = (data as? String)?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
                            if !sharedTexts.contains(text) {
                                sharedTexts.append(text)
                            }
                        }
                        lock.unlock()
                        group.leave()
                    }
                } else if provider.hasItemConformingToTypeIdentifier(UTType.data.identifier) {
                    group.enter()
                    loadFileItem(provider: provider, typeIdentifier: UTType.data.identifier, dir: shareDir, fallbackExt: "dat", mimeType: "application/octet-stream") { fileInfo, ok in
                        lock.lock()
                        if let fileInfo = fileInfo {
                            copiedFiles.append(fileInfo)
                            if firstKind == nil { firstKind = "file" }
                        } else if !ok {
                            hadError = true
                        }
                        lock.unlock()
                        group.leave()
                    }
                }
            }
        }

        group.notify(queue: .main) {
            var payload: [String: Any] = [
                "source": "external",
                "createdAtMs": Int(Date().timeIntervalSince1970 * 1000),
                "files": copiedFiles
            ]

            let combinedText = sharedTexts.joined(separator: "\n")
            if !combinedText.isEmpty {
                payload["text"] = combinedText
            }
            if let firstUrl = sharedUrls.first, !firstUrl.isEmpty {
                payload["url"] = firstUrl
            }

            if let kind = firstKind {
                payload["kind"] = kind
            } else if !sharedUrls.isEmpty {
                payload["kind"] = "link"
            } else if hadError && copiedFiles.isEmpty && combinedText.isEmpty {
                payload["kind"] = "file"
                payload["error"] = "read_failed"
            } else {
                payload["kind"] = "text"
            }

            if let defaults = UserDefaults(suiteName: self.appGroupId),
               let jsonData = try? JSONSerialization.data(withJSONObject: payload),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                defaults.set(jsonString, forKey: self.pendingDefaultsKey)
                defaults.synchronize()
            }

            self.openHostApp()
        }
    }

    private func loadFileItem(
        provider: NSItemProvider,
        typeIdentifier: String,
        dir: URL?,
        fallbackExt: String,
        mimeType: String,
        completion: @escaping ([String: Any]?, Bool) -> Void
    ) {
        provider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
            if let url = url {
                if let info = self.copyLocalFile(url: url, dir: dir, fallbackExt: fallbackExt, mimeType: self.mimeTypeForPath(url.path) ?? mimeType) {
                    completion(info, true)
                    return
                }
            }

            provider.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { data, _ in
                if let fileUrl = data as? URL,
                   let info = self.copyLocalFile(url: fileUrl, dir: dir, fallbackExt: fallbackExt, mimeType: self.mimeTypeForPath(fileUrl.path) ?? mimeType) {
                    completion(info, true)
                } else {
                    completion(nil, error == nil)
                }
            }
        }
    }

    private func loadImageItem(
        provider: NSItemProvider,
        dir: URL?,
        completion: @escaping ([String: Any]?, Bool) -> Void
    ) {
        provider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, _ in
            if let url = url,
               let info = self.copyLocalFile(url: url, dir: dir, fallbackExt: "jpg", mimeType: self.mimeTypeForPath(url.path) ?? "image/jpeg") {
                completion(info, true)
                return
            }
            provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { data, _ in
                if let fileUrl = data as? URL,
                   let info = self.copyLocalFile(url: fileUrl, dir: dir, fallbackExt: "jpg", mimeType: self.mimeTypeForPath(fileUrl.path) ?? "image/jpeg") {
                    completion(info, true)
                    return
                }
                if let image = data as? UIImage,
                   let jpegData = image.jpegData(compressionQuality: 0.9),
                   let dir = dir {
                    let name = "shared_\(Int(Date().timeIntervalSince1970 * 1000)).jpg"
                    let dest = dir.appendingPathComponent(name)
                    do {
                        try jpegData.write(to: dest)
                        completion([
                            "path": dest.path,
                            "name": name,
                            "mimeType": "image/jpeg",
                            "sizeBytes": jpegData.count
                        ], true)
                        return
                    } catch {}
                }
                completion(nil, false)
            }
        }
    }

    private func sharedIntakeDirectory() -> URL? {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) else {
            return nil
        }
        let dir = container.appendingPathComponent("share_intake", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func copyLocalFile(url: URL, dir: URL?, fallbackExt: String, mimeType: String?) -> [String: Any]? {
        guard let dir = dir else { return nil }
        let rawName = url.lastPathComponent.isEmpty
            ? "shared_\(Int(Date().timeIntervalSince1970 * 1000)).\(fallbackExt)"
            : url.lastPathComponent
        let sanitized = rawName.replacingOccurrences(of: "[^a-zA-Z0-9._-]", with: "_", options: .regularExpression)
        let finalName = "\(Int(Date().timeIntervalSince1970 * 1000))_\(sanitized)"
        let dest = dir.appendingPathComponent(finalName)

        do {
            if FileManager.default.fileExists(atPath: dest.path) {
                try FileManager.default.removeItem(at: dest)
            }
            try FileManager.default.copyItem(at: url, to: dest)
            let attrs = try? FileManager.default.attributesOfItem(atPath: dest.path)
            let size = (attrs?[.size] as? NSNumber)?.intValue ?? 0
            var info: [String: Any] = [
                "path": dest.path,
                "name": sanitized,
                "sizeBytes": size
            ]
            if let mimeType = mimeType {
                info["mimeType"] = mimeType
            }
            return info
        } catch {
            return nil
        }
    }

    private func mimeTypeForPath(_ path: String) -> String? {
        let ext = URL(fileURLWithPath: path).pathExtension.lowercased()
        if let utType = UTType(filenameExtension: ext), let mime = utType.preferredMIMEType {
            return mime
        }
        return nil
    }

    private func kindFromMime(_ mime: String?) -> String {
        let m = (mime ?? "").lowercased()
        if m.hasPrefix("image/") { return "image" }
        if m.hasPrefix("video/") { return "video" }
        if m.hasPrefix("audio/") { return "audio" }
        return "file"
    }

    private func openHostApp() {
        var responder: UIResponder? = self
        let selector = sel_registerName("openURL:")
        while let current = responder {
            if current.responds(to: selector) {
                current.perform(selector, with: hostShareUrl)
                break
            }
            responder = current.next
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.finishExtension()
        }
    }

    private func finishExtension() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
