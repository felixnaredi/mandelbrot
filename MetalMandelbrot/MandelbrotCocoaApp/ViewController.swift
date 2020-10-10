//
//  PreviewController.swift
//  MandelbrotCocoaApp
//
//  Created by Felix Naredi on 2020-10-10.
//

import Cocoa
import simd

/// Mapping for the key and key code value from `NSEvent`.
fileprivate enum Key: UInt16 {
  case a     =  0
  case s     =  1
  case d     =  2
  case h     =  4
  case z     =  6
  case x     =  7
  case c     =  8
  case w     = 13
  case r     = 15
  case plus  = 27
  case minus = 44
  case space = 49
}

/// The different kind of modes that a `HelpTextView` can display.
fileprivate enum HelpTextMode {
  case showNothing
  case showKeyControlls
  case showState
  
  static func repeating(startingAt mode: HelpTextMode) -> UnfoldFirstSequence<HelpTextMode>
  {
    return sequence(first: mode, next: { current in
      switch current {
      case .showNothing:
        return .showKeyControlls
      case .showKeyControlls:
        return .showState
      case .showState:
        return .showNothing
      }
    })
  }
}

/// The view controller for the view displaying the Mandelbrot set and help text.
class ViewController: NSViewController {
  @IBOutlet weak var helpTextView: HelpTextView?
  
  private var keysDown = Set<Key>()
  private var maxIterations = Float(10)
  private var zDirection = Float(-1.0)
  private var threshold = Float(5.0)
  private var deltaPosition = SIMD3<Float>(-0.1, 0.0, 0.0)
  private var position = SIMD3<Float>(0.0, 0.0, 1.7)
  
  // `helpTextMode` is handed the first element of the sequence `helpTextModeSequence` when the view
  // loads. Thus it is just given a placeholder value on initialization.
  private var helpTextMode = HelpTextMode.showNothing
  private var helpTextModeSequence = HelpTextMode.repeating(startingAt: .showKeyControlls)
  
  private var x: Float { position.x }
  private var y: Float { position.y }
  private var z: Float { position.z }
  
  /// Process input and updates the views if necessary.
  func step() {
    if keysDown.contains(.plus) { maxIterations += 0.45 }
    if keysDown.contains(.minus) { maxIterations -= 0.45 }
    if keysDown.contains(.z) { threshold *= 0.99 }
    if keysDown.contains(.x) { threshold *= 1.01 }
    
    if keysDown.contains(.w) { deltaPosition.y += 0.0050; }
    if keysDown.contains(.s) { deltaPosition.y -= 0.0050; }
    if keysDown.contains(.a) { deltaPosition.x -= 0.0050; }
    if keysDown.contains(.d) { deltaPosition.x += 0.0050; }
    if keysDown.contains(.space) { deltaPosition.z += 0.0025 * zDirection; }
    deltaPosition *= 0.85
    position += deltaPosition * position.z
    
    if (needsRender) {
      if (helpTextMode == .showState) { updateHelpText() }
      renderView()
    }
  }
  
  override func viewDidLoad() {
    helpTextMode = helpTextModeSequence.next()!
    updateHelpText()
    renderView()
  }
  
  override func keyDown(with event: NSEvent) {
    print("PreviewController::keyDown - keyCode: \(event.keyCode)")
    
    guard let keyCode = Key(rawValue: event.keyCode) else { return }
    
    keysDown.insert(keyCode)
    
    // Handle input that should only trigger on the key down event.
    switch keyCode {
    case .h:
      helpTextMode = helpTextModeSequence.next()!
      updateHelpText()
    case .r:
      zDirection *= -1
    default:
      break
    }
  }
  
  override func keyUp(with event: NSEvent) {
    guard let keyCode = Key(rawValue: event.keyCode) else { return }
    keysDown.remove(keyCode)
  }
  
  private func updateHelpText() {
    switch helpTextMode {
    case .showNothing:
      helpTextView?.isHidden = true
    case .showKeyControlls:
      helpTextView?.isHidden = false
      helpTextView?.setText([
        "    h : toggle help text",
        "    w : move up",
        "    a : move left",
        "    s : move down",
        "    d : move right",
        "space : zoom",
        "    r : toggle zoom in/out",
        "    + : increase iterations",
        "    - : decrease iterations",
        "    z : increase threshold",
        "    x : decrease threshold",
      ])
    case .showState:
      helpTextView?.isHidden = false
      helpTextView?.setText([
        "            x : \(x)",
        "            y : \(y)",
        "            z : \(z)",
        "maxIterations : \(UInt(maxIterations))",
        "    threshold : \(threshold)",
        "   zDirection : \(zDirection)"
      ])
    }
  }
  
  private func renderView() {
    let view = self.view as! PreviewView
    let renderer = view.renderer
    
    renderer.modelMatrix = float4x4(columns:( [z, 0, 0, x],
                                              [0, z, 0, y],
                                              [0, 0, 1, 0],
                                              [0, 0, 0, 1]))
    renderer.iterations = UInt32(maxIterations)
    renderer.threshold = threshold
    view.needsDisplay = true
  }
  
  private var needsRender: Bool {
    if (!keysDown.isEmpty) { return true }
    for v in [deltaPosition.x, deltaPosition.y, deltaPosition.z] {
      if abs(v) > 1e-5 { return true }
    }
    return false
  }
}
