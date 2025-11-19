import Vision
import UIKit

private let border_line_width: CGFloat = 2
private let highlight_fill_color: UIColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.3)

struct TextRecognitionResult: Sendable {
  let text: String
  let rect: CGRect
}

fileprivate actor TextRecognitionActor {
  func recognizeText(image: UIImage) async -> [TextRecognitionResult] {
    guard let cgImage = image.cgImage else {
      return []
    }
    return await withCheckedContinuation { continuation in
      let request = VNRecognizeTextRequest { (request, error) in
        guard
          error == nil,
          let observations = request.results as? [VNRecognizedTextObservation]
        else {
          continuation.resume(returning: [])
          return
        }
        
        // Vision's origin is on bottom left
        let transform = CGAffineTransform.identity
          .scaledBy(x: 1, y: -1)
          .translatedBy(x: 0, y: -image.size.height)
          .scaledBy(x: image.size.width, y: image.size.height)
        
        let results: [TextRecognitionResult] = observations.compactMap { observation in
          guard let text = observation.topCandidates(1).first else { return nil }
          let rect = observation.boundingBox.applying(transform)
          return TextRecognitionResult(text: text.string, rect: rect)
        }
        continuation.resume(returning: results)
      }
      
      // Fast mode works poorly. Accurate is not too slow.
      request.recognitionLevel = .accurate
      
      let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
      try? handler.perform([request])
    }
  }
}

enum TextRecognitionUtil {
  
  private static let actor = TextRecognitionActor()
  
  static func recognizeText(image: UIImage) async -> [TextRecognitionResult] {
    return await actor.recognizeText(image: image)
  }
  
  static func visualize(image: UIImage, results: [TextRecognitionResult]) -> UIImage {
    
    UIGraphicsBeginImageContextWithOptions(image.size, true, 1)
    let ctx = UIGraphicsGetCurrentContext()!
    image.draw(in: CGRect(origin: .zero, size: image.size))
    ctx.saveGState()
    ctx.setLineWidth(border_line_width)
    ctx.setLineJoin(.round)
    ctx.setStrokeColor(UIColor.black.cgColor)
    ctx.setFillColor(highlight_fill_color.cgColor)
    
    results.forEach { result in
      ctx.addRect(result.rect)
    }
    ctx.drawPath(using: .fillStroke)
    ctx.restoreGState()
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
  }
  
}
