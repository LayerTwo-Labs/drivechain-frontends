import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var backendHome: URL?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    do {
      backendHome = try AppDelegate.prepareBackendHome(
        in: FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0])
    } catch {
      fatalError("prepare the backend home: \(error)")
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Creates the backend home in [parent]. The home holds the wallet seed, so
  /// it stays out of the iCloud and device backups.
  static func prepareBackendHome(in parent: URL) throws -> URL {
    var home = parent.appendingPathComponent("BitWindowHome", isDirectory: true)
    try FileManager.default.createDirectory(at: home, withIntermediateDirectories: true)
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    try home.setResourceValues(values)
    return home
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "BitWindowNative") else {
      fatalError("no registrar for the native channel")
    }
    let channel = FlutterMethodChannel(
      name: "com.layertwolabs.bitwindow/native", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      // Dart cannot read the process environment on iOS, so it asks for BITWINDOW_HOME.
      case "backendHome":
        guard let home = self?.backendHome else {
          result(FlutterError(code: "no_home", message: "the backend home is not ready", details: nil))
          return
        }
        result(home.path)
      case "openUrl":
        guard let raw = call.arguments as? String, let url = URL(string: raw) else {
          result(FlutterError(code: "bad_url", message: "not a URL: \(String(describing: call.arguments))", details: nil))
          return
        }
        UIApplication.shared.open(url) { opened in
          if opened {
            result(nil)
          } else {
            result(FlutterError(code: "no_handler", message: "nothing opens \(raw)", details: nil))
          }
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
