import VisionKit
import UIKit
import AVFoundation

@MainActor
enum DocumentScanUtil {
  
  static func scan(navVC: UINavigationController, compressionQuality: CGFloat) async -> UIImage? {
    guard await PermissionUtil.requestCameraPermissionIfSupportedInInfoPlist(vc: navVC) else {
      fatalError("You must enable camera permission")
    }
    return await withCheckedContinuation { continuation in
      let cameraVC = VNDocumentCameraViewController()
      let delegate = DocumentScanDelegate.shared
      delegate.compressionQuality = compressionQuality
      delegate.continuation = continuation
      delegate.navVC = navVC
      cameraVC.delegate = delegate
      navVC.pushViewController(cameraVC, animated: true)
    }
  }
}

fileprivate class DocumentScanDelegate: NSObject, VNDocumentCameraViewControllerDelegate {
  
  @MainActor
  static let shared = DocumentScanDelegate()
  
  var compressionQuality: CGFloat = 1
  var continuation: CheckedContinuation<UIImage?, Never>! = nil
  var navVC: UINavigationController!
  
  func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
    Task { @MainActor in
      navVC.popViewController(animated: true)
    }
    
    guard scan.pageCount >= 1 else { return }
    // We only want 1 single page (Unfortunately DocumentCameraVC does not support customization.
    // Assume user only want the last page.
    let lastPage = scan.imageOfPage(at: scan.pageCount - 1)
    let compressed = lastPage.compressed(quality: compressionQuality)
    continuation.resume(returning: compressed)
  }
  
  func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
    Task { @MainActor in
      navVC.popViewController(animated: true)
    }
    continuation.resume(returning: nil)
  }
  
  func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
    Task { @MainActor in
      navVC.popViewController(animated: true)
    }
    continuation.resume(returning: nil)
  }
}
