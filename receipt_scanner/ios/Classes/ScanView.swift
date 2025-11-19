import Vision
import SwiftUI

private let padding_scanned_image: CGFloat = 32

enum ScanState {
  case empty
  case noAmountDetected
  case someAmountsDetected
  
  var instructionLabel: String {
    switch self {
    case .empty:
      return "Scan receipt to detect bill amount"
    case .noAmountDetected:
      return "No bill amount detected. Please try again"
    case .someAmountsDetected:
      return "The bill amount detected. Tap the highlighted region to confirm"
    }
  }
}

struct ScanView: View {
  
  @State
  private var detectedTexts: [TextRecognitionResult] = []
  
  @State
  private var image: UIImage? = nil
  
  let navVC: UINavigationController
  let onResult: (Decimal) -> Void
  
  private var scanState: ScanState {
    if image == nil {
      return .empty
    } else {
      if detectedTexts.isEmpty {
        return .noAmountDetected
      } else {
        return .someAmountsDetected
      }
    }
  }
  
  private func launchScanner() {
    Task {
      if let (image, texts) = await ReceiptScanner.scanAndDetectMoney(navVC: navVC) {
        self.image = image
        self.detectedTexts = texts
      }
    }
  }
  
  
  @ViewBuilder
  private func imageRegion(image: UIImage) -> some View {
    GeometryReader { geo in
      SUIImage(
        uiImage: image,
        rendering: .original,
        sizing: .autoSizing(scaling: .fit))
        .gesture(DragGesture(minimumDistance: 0).onEnded({ value in
          
          let scaleFactor = min(
            geo.size.width / image.size.width,
            geo.size.height / image.size.height)
          
          let location = value.location / scaleFactor
          
          for text in detectedTexts {
            if text.rect.contains(location) {
              let billedAmount = text.moneyAmount ?? .zero
              onResult(billedAmount)
              navVC.dismiss(animated: true)
              break
            }
          }
        }))
        .position(CGPoint(x: geo.size.width/2, y: geo.size.height/2))
    }
    .aspectRatio(image.aspectRatio, contentMode: .fit)
  }
  
  
  var body: some View {
    VStack {
      Spacer()
      Text(scanState.instructionLabel)
      
      if let image {
        imageRegion(image: image)
          .padding(padding_scanned_image)
      }
      Spacer()
    }
    .toolbar {
      ToolbarItemGroup(placement: .navigationBarTrailing) {
        Button("Scan") {
          launchScanner()
        }
      }
    }
    .onFirstAppearRunAsync {
      launchScanner()
    }
  }
}

