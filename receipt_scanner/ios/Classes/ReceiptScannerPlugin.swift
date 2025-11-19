import Flutter
import UIKit
import SwiftUI

public class ReceiptScannerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "receipt_scanner", binaryMessenger: registrar.messenger())
    let instance = ReceiptScannerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  private func presentScanView(onResult: @escaping (Decimal) -> Void) {
    let navVC = UINavigationController()
    let scanView = ScanView(navVC: navVC, onResult: onResult)
    let vc = UIHostingController(rootView: scanView)
    navVC.setViewControllers([vc], animated: false)
    ROOT_VC.present(navVC, animated: true)
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        self.presentScanView { amount in
          result("amount is: \(amount)")
        }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

public var ROOT_VC: UIViewController! {
  let scenes = UIApplication.shared.connectedScenes
  let windowScene = scenes
    .filter { $0.activationState == .foregroundActive }
    .first(where: { $0 is UIWindowScene }) as? UIWindowScene
  let rootVC = windowScene?.windows
    .first(where: { $0.isKeyWindow })?
    .rootViewController
  return rootVC
}
