import SwiftUI


fileprivate struct OnFirstAppearRunAsyncModifier: ViewModifier {
  @State
  private var appeared = false
  
  let block: () -> Void
  
  func body(content: Content) -> some View {
    content.onAppearRunAsync {
      if !appeared {
        appeared = true
        block()
      }
    }
  }
}

extension View {
  func onAppearRunAsync(block: @escaping @MainActor @Sendable () -> Void) -> some View {
    onAppear {
      DispatchQueue.main.async(execute: block)
    }
  }
  
  func onFirstAppearRunAsync(block: @escaping () -> Void) -> some View {
    modifier(OnFirstAppearRunAsyncModifier(block: block))
  }
}


extension View {
  @ViewBuilder
  func foregroundStyleIfNeeded<S: ShapeStyle>(_ style: S?) -> some View {
    if let style {
      foregroundStyle(style)
    } else {
      self
    }
  }
}

extension View {
  @ViewBuilder
  func scale(mode: ScalingMode) -> some View {
    switch mode {
    case .noScale:
      self
    case .fit:
      scaledToFit()
    case .fill:
      scaledToFill()
    }
  }
}


public enum ScalingMode {
  case noScale
  case fit
  case fill
}

extension Image {
  func resizableIf(
    _ condition: Bool,
    capInsets: EdgeInsets = EdgeInsets(),
    resizingMode: Image.ResizingMode = .stretch) -> Image
  {
    if condition {
      return self.resizable(capInsets: capInsets, resizingMode: resizingMode)
    } else {
      return self
    }
  }
  
}

