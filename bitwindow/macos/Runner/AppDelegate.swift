import Cocoa
import Darwin
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var terminating = false

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  // Cmd+Q / AppleScript `quit` / Apple-menu "Quit BitWindow" route through
  // NSApplication.terminate(), which bypasses window_manager.setPreventClose
  // (that only hooks NSWindowDelegate.windowShouldClose:). Without this
  // override the app would exit immediately and leave bitwindowd +
  // orchestratord orphaned. Instead, cancel the terminate and raise SIGINT
  // on ourselves so setupSignalHandlers in main.dart runs BinaryProvider
  // .onShutdown() and exits cleanly.
  override func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
    if terminating {
      return .terminateNow
    }
    terminating = true
    kill(getpid(), SIGINT)
    return .terminateCancel
  }
}
