import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ShipKiaDocuments") else { return }
    let channel = FlutterMethodChannel(name: "shipkia/documents", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "exportPdf" else { result(FlutterMethodNotImplemented); return }
      guard let args = call.arguments as? [String: Any], let bytes = args["bytes"] as? FlutterStandardTypedData,
            let name = args["name"] as? String else { result(FlutterError(code: "invalid", message: "Missing PDF", details: nil)); return }
      do {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent((name as NSString).lastPathComponent)
        try bytes.data.write(to: url)
        guard var presenter = self?.window?.rootViewController else {
          try? FileManager.default.removeItem(at: directory)
          result(FlutterError(code: "export_failed", message: "No active window", details: nil)); return
        }
        while let next = presenter.presentedViewController { presenter = next }
        let sheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        sheet.popoverPresentationController?.sourceView = presenter.view
        sheet.popoverPresentationController?.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 1, height: 1)
        sheet.completionWithItemsHandler = { _, completed, _, error in
          try? FileManager.default.removeItem(at: directory)
          if let error = error { result(FlutterError(code: "export_failed", message: error.localizedDescription, details: nil)) }
          else { result(completed) }
        }
        presenter.present(sheet, animated: true)
      } catch { result(FlutterError(code: "export_failed", message: error.localizedDescription, details: nil)) }
    }
  }
}
