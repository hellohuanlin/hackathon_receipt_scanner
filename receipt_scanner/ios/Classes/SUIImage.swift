import SwiftUI

struct SUIImage: View {
  
  enum Rendering {
    case systemTint
    case customColor(color: UIColor)
    case original
  }
  
  enum Sizing {
    case intrinsic
    case autoSizing(scaling: ScalingMode)
    case fixed(size: CGSize, scaling: ScalingMode)
  }
  
  private let uiImage: UIImage
  private let sizing: Sizing
  private let rendering: Rendering
  
  init(uiImage: UIImage, rendering: Rendering, sizing: Sizing) {
    self.uiImage = uiImage
    self.rendering = rendering
    self.sizing = sizing
  }
  
  var body: some View {
    
    let foregroundColor = rendering.color.map { Color(cgColor: $0.cgColor) }
    let size = sizing.sizeForImageImplementation
    
    Image(uiImage: uiImage)
      .resizableIf(sizing.resizableForImageImplementation)
      .renderingMode(rendering.mode)
      .foregroundStyleIfNeeded(foregroundColor)
      .frame(width: size?.width, height: size?.height)
      .scale(mode: sizing.scalingMode)
  }
}

fileprivate extension SUIImage.Rendering {
  
  var mode: Image.TemplateRenderingMode {
    switch self {
    case .systemTint:
      return .template
    case .customColor:
      return .template
    case .original:
      return .original
    }
  }
  var color: UIColor? {
    switch self {
    case .systemTint:
      return nil
    case .customColor(let color):
      return color
    case .original:
      return nil
    }
  }
}

fileprivate extension SUIImage.Sizing {
  
  var resizableForImageImplementation: Bool {
    switch self {
    case .autoSizing:
      return true
    case .intrinsic:
      return false
    case .fixed:
      return true
    }
  }
  
  var sizeForImageImplementation: CGSize? {
    switch self {
    case .autoSizing:
      return nil
    case .intrinsic:
      return nil
    case .fixed(let size, _):
      return size
    }
  }
  
  var scalingMode: ScalingMode {
    switch self {
    case .intrinsic:
      return .noScale
    case .autoSizing(let scaling):
      return scaling
    case .fixed(_, let scaling):
      return scaling
    }
  }
}
