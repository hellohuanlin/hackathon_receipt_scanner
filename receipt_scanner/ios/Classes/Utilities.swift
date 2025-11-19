import UIKit

extension UIImage {
  func compressed(quality: CGFloat) -> UIImage {
    guard let data = jpegData(compressionQuality: quality),
          let compressed = UIImage(data: data)
    else { return self }
    return compressed
  }
  
  var aspectRatio: CGFloat {
    return size.width / size.height
  }
}

extension Collection {
  func anySatisfy(_ p: (Element) -> Bool) -> Bool {
    return !self.allSatisfy { !p($0) }
  }
}

func *(p: CGPoint, scaler: CGFloat) -> CGPoint {
  return CGPoint(x: p.x * scaler, y: p.y * scaler)
}

func /(p: CGPoint, scaler: CGFloat) -> CGPoint {
  return p * (CGFloat(1) / scaler)
}
