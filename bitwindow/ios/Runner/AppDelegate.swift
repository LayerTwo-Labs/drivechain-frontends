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
      case "shareFile":
        guard let path = call.arguments as? String else {
          result(FlutterError(code: "bad_path", message: "not a path: \(String(describing: call.arguments))", details: nil))
          return
        }
        guard FileManager.default.fileExists(atPath: path) else {
          result(FlutterError(code: "missing", message: "no file at \(path)", details: nil))
          return
        }
        guard let presenter = self?.topViewController() else {
          result(FlutterError(code: "no_view", message: "no view to show the share sheet on", details: nil))
          return
        }
        let sheet = UIActivityViewController(activityItems: [URL(fileURLWithPath: path)], applicationActivities: nil)
        if let popover = sheet.popoverPresentationController {
          popover.sourceView = presenter.view
          popover.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 0, height: 0)
          popover.permittedArrowDirections = []
        }
        presenter.present(sheet, animated: true)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func topViewController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    var top = scenes.flatMap(\.windows).first(where: \.isKeyWindow)?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }
}
