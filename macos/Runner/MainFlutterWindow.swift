import Cocoa
import FlutterMacOS

class MainFlutterWindow: FlutterWindow {
  override func bitsTheAppIsRunningOnDarkBackground() -> Bool {
    return true // Force dark mode
  }
}