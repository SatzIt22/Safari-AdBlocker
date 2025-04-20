import Cocoa
import SafariServices

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the status bar item
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "shield", accessibilityDescription: "Ad Blocker")
            button.action = #selector(togglePopover(_:))
        }
        
        createWindow()
        checkExtensionState()
    }
    
    func createWindow() {
        let windowSize = NSSize(width: 400, height: 300)
        let screenSize = NSScreen.main?.frame.size ?? NSSize(width: 800, height: 600)
        let rect = NSMakeRect(
            (screenSize.width - windowSize.width) / 2,
            (screenSize.height - windowSize.height) / 2,
            windowSize.width,
            windowSize.height
        )
        
        window = NSWindow(contentRect: rect, styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
        window.title = "Safari Ad Blocker"
        window.contentViewController = MainViewController()
        window.isReleasedWhenClosed = false
    }
    
    @objc func togglePopover(_ sender: Any?) {
        if window.isVisible {
            window.orderOut(nil)
        } else {
            window.makeKeyAndOrderFront(nil)
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }
    
    func checkExtensionState() {
        SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: "com.yourdomain.AdBlocker.ContentBlocker") { (state, error) in
            guard let state = state else {
                print("Error checking content blocker state: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                if let viewController = self.window.contentViewController as? MainViewController {
                    viewController.updateStatus(enabled: state.isEnabled)
                }
            }
        }
    }
}