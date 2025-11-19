import VisionKit
import UIKit
import AVFoundation

@MainActor
enum DocumentScanUtil {
  
  static func scan(vc: UIViewController, compressionQuality: CGFloat) async -> UIImage? {
    guard await PermissionUtil.requestCameraPermissionIfSupportedInInfoPlist(vc: vc) else {
      return nil
    }
    return await withCheckedContinuation { continuation in
      let cameraVC = VNDocumentCameraViewController()
      let delegate = DocumentScanDelegate.shared
      delegate.compressionQuality = compressionQuality
      delegate.continuation = continuation
      cameraVC.delegate = delegate
      vc.present(cameraVC, animated: true)
    }
  }
}

fileprivate class DocumentScanDelegate: NSObject, VNDocumentCameraViewControllerDelegate {
  
  @MainActor
  static let shared = DocumentScanDelegate()
  
  var compressionQuality: CGFloat = 1
  var continuation: CheckedContinuation<UIImage?, Never>! = nil
  
  func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
    Task { @MainActor in
      controller.dismiss(animated: true)
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
      controller.dismiss(animated: true)
    }
    continuation.resume(returning: nil)
  }
  
  func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
    Task { @MainActor in
      controller.dismiss(animated: true)
    }
    continuation.resume(returning: nil)
  }
}

public extension UIImage {
  func compressed(quality: CGFloat) -> UIImage {
    guard let data = jpegData(compressionQuality: quality),
          let compressed = UIImage(data: data)
    else { return self }
    return compressed
  }
}
