import Flutter
import AVFoundation

final class AudioRouteBridge {

  private static let bluetoothPorts: [AVAudioSession.Port] = [
    .bluetoothHFP, .bluetoothA2DP, .bluetoothLE
  ]

  private static func isBluetoothOutput(_ s: AVAudioSession) -> Bool {
    return s.currentRoute.outputs.contains { bluetoothPorts.contains($0.portType) }
  }

  private static func setBluetoothOptions(_ s: AVAudioSession, enabled: Bool) {
    var opts = s.categoryOptions
    if enabled {
      opts.insert(.allowBluetooth)
      opts.insert(.allowBluetoothA2DP)
    } else {
      opts.remove(.allowBluetooth)
      opts.remove(.allowBluetoothA2DP)
    }
    do {
      try s.setCategory(s.category, mode: s.mode, options: opts)
    } catch {
      NSLog("[AudioRoute][native] setCategory failed: \(error)")
    }
  }

  private static func builtInMic(_ s: AVAudioSession) -> AVAudioSessionPortDescription? {
    return s.availableInputs?.first(where: { $0.portType == .builtInMic })
  }

  private static func describe(_ ports: [AVAudioSessionPortDescription]?) -> String {
    guard let ports = ports, !ports.isEmpty else { return "none" }
    return ports.map { "\($0.portType.rawValue)(\($0.portName))" }.joined(separator: ", ")
  }

  /// Full snapshot of the REAL audio session, for debugging.
  private static func dump(_ s: AVAudioSession) -> String {
    let o = s.categoryOptions
    var opts: [String] = []
    if o.contains(.allowBluetooth) { opts.append("allowBluetooth") }
    if o.contains(.allowBluetoothA2DP) { opts.append("allowBluetoothA2DP") }
    if o.contains(.defaultToSpeaker) { opts.append("defaultToSpeaker") }
    if o.contains(.mixWithOthers) { opts.append("mixWithOthers") }
    if o.contains(.allowAirPlay) { opts.append("allowAirPlay") }

    let text =
        "category=\(s.category.rawValue) mode=\(s.mode.rawValue) " +
            "options=[\(opts.joined(separator: ","))] " +
            "OUTPUTS=[\(describe(s.currentRoute.outputs))] " +
            "INPUTS=[\(describe(s.currentRoute.inputs))] " +
            "AVAILABLE_INPUTS=[\(describe(s.availableInputs))] " +
            "preferredInput=\(s.preferredInput?.portType.rawValue ?? "none")"

    NSLog("[AudioRoute][native] \(text)")
    return text
  }

  static func register(with messenger: FlutterBinaryMessenger) {
    NSLog("[AudioRoute][native] bridge registered")

    let channel = FlutterMethodChannel(
        name: "fgtracker/audio_route",
        binaryMessenger: messenger
    )

    channel.setMethodCallHandler { call, result in
      let session = AVAudioSession.sharedInstance()
      NSLog("[AudioRoute][native] call: \(call.method)")

      switch call.method {

      case "dumpRoute":
        result(dump(session))

          // Returns "preferred" | "blocked" | "failed"
      case "forceEarpiece":
        do { try session.overrideOutputAudioPort(.none) }
        catch { NSLog("[AudioRoute][native] override none failed: \(error)") }

        if let mic = builtInMic(session) {
          do { try session.setPreferredInput(mic) }
          catch { NSLog("[AudioRoute][native] setPreferredInput(builtIn) failed: \(error)") }
        } else {
          NSLog("[AudioRoute][native] built-in mic NOT in availableInputs")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
          _ = dump(session)
          if !isBluetoothOutput(session) {
            result("preferred")
            return
          }

          NSLog("[AudioRoute][native] still Bluetooth -> removing Bluetooth options")
          setBluetoothOptions(session, enabled: false)
          if let mic = builtInMic(session) { try? session.setPreferredInput(mic) }

          DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            _ = dump(session)
            result(isBluetoothOutput(session) ? "failed" : "blocked")
          }
        }

      case "forceSpeaker":
        do {
          try session.overrideOutputAudioPort(.speaker)
          result(true)
        } catch {
          NSLog("[AudioRoute][native] override speaker failed: \(error)")
          result(false)
        }

      case "allowBluetooth":
        setBluetoothOptions(session, enabled: true)
        result(true)

      case "preferBluetooth":
        setBluetoothOptions(session, enabled: true)
        do { try session.overrideOutputAudioPort(.none) }
        catch { NSLog("[AudioRoute][native] override none failed: \(error)") }

        if let bt = session.availableInputs?.first(where: { bluetoothPorts.contains($0.portType) }) {
          do { try session.setPreferredInput(bt) }
          catch { NSLog("[AudioRoute][native] setPreferredInput(bt) failed: \(error)") }
          result(true)
        } else {
          NSLog("[AudioRoute][native] no Bluetooth input available")
          result(false)
        }

      case "currentRoute":
        result(session.currentRoute.outputs.first?.portType.rawValue)

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}