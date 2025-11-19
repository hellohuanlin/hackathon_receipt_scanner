import Foundation
import AppTrackingTransparency
import AVFoundation
import UIKit

enum InfoPlistKey: String {
  case cameraPermissionDescription = "NSCameraUsageDescription"
}

enum PermissionType {
  case camera
  
  var infoPlistKey: InfoPlistKey {
    switch self {
    case .camera:
      return .cameraPermissionDescription
    }
  }
}

@MainActor
enum PermissionUtil {
  
  private static func description(_ permission: PermissionType) -> String? {
    return Bundle.main.object(forInfoDictionaryKey: permission.infoPlistKey.rawValue) as? String
  }
  
  static func isSupportedInInfoPlist(_ permission: PermissionType) -> Bool {
    return description(permission) != nil
  }
  
  static func requestCameraPermissionIfSupportedInInfoPlist(vc: UIViewController) async -> Bool {
    
    guard isSupportedInInfoPlist(.camera), let description = description(.camera) else {
      return false
    }
    
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    switch status {
    case .notDetermined:
      // request permission
      return await AVCaptureDevice.requestAccess(for: .video)
    case .authorized:
      // directly launch
      return true
    case _:
      // denied or restricted (e.g. parental control)
      return await withCheckedContinuation { continuation in
        AlertUtil.actionAlert(
          in: vc,
          title: "Permission needed",
          message: "Go to settings to enable camera permission",
          cancelTitle: "Cancel",
          actionTitle: "OK")
        {
          UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
          continuation.resume(returning: false)
        }
      }
    }
  }
}

