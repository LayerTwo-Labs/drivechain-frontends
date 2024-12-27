import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var methodChannel: FlutterMethodChannel?
    
  override func applicationDidFinishLaunching(_ aNotification: Notification) {
    let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
    methodChannel = FlutterMethodChannel(
        name: "com.layertwolabs.bitwindow/menu",
        binaryMessenger: controller.engine.binaryMessenger)
    
    super.applicationDidFinishLaunching(aNotification)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
  
  @IBAction func openHashCalculator(_ sender: Any) {
    methodChannel?.invokeMethod("openTool", arguments: "hashCalculator")
  }
  
  @IBAction func openMultisigLounge(_ sender: Any) {
    methodChannel?.invokeMethod("openTool", arguments: "multisigLounge")
  }
  
  @IBAction func openProofOfFunds(_ sender: Any) {
    methodChannel?.invokeMethod("openTool", arguments: "proofOfFunds")
  }
}
