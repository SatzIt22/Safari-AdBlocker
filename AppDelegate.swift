import Cocoa
import SafariServices

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    // Status bar item reference
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    // Popover for the status UI
    private let popover = NSPopover()
    private var popoverViewController: StatusPopoverViewController!

    // Store the extension's bundle identifier - read from Info.plist or define as a constant
    // IMPORTANT: Replace "com.yourdomain.AdBlocker.ContentBlocker" with your actual extension bundle ID
    private let contentBlockerExtensionBundleIdentifier = "com.yourdomain.AdBlocker.ContentBlocker" // <-- Set your extension's Bundle ID here

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Set up the status bar item button
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "shield", accessibilityDescription: "Ad Blocker")
            // Use the button's action to toggle the popover
            button.action = #selector(togglePopover(_:))
            button.target = self // Set the target to AppDelegate
        }

        // Set up the popover and its content view controller
        setupPopover()

        // Initial check for extension state
        checkExtensionState()

        // MARK: - Future Enhancement: Schedule periodic rule updates
        // You would likely want to fetch and compile updated ad blocking rules periodically.
        // This is where you might schedule a timer or background task.
        // scheduleRuleUpdates()
    }

    // MARK: - Popover Management

    private func setupPopover() {
        popoverViewController = StatusPopoverViewController()
        // Pass the status item so the popover can position itself relative to it
        popoverViewController.statusItem = statusItem

        popover.contentViewController = popoverViewController
        popover.behavior = .transient // Dismisses when clicking outside
    }

    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }

    private func showPopover(sender: Any?) {
        if let button = statusItem.button {
            // Show the popover anchored to the status item button
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            // Activate the application to bring it to the front and handle events
            NSApplication.shared.activate(ignoringOtherApps: true)
             // Re-check state whenever the popover is shown
            checkExtensionState()
        }
    }

    private func closePopover(sender: Any?) {
        popover.performClose(sender)
    }

    // MARK: - Extension State Check

    func checkExtensionState() {
        SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: contentBlockerExtensionBundleIdentifier) { [weak self] (state, error) in
            // Always dispatch UI updates to the main thread
            DispatchQueue.main.async {
                guard let self = self else { return } // Self might be nil if the app is closing

                if let error = error {
                    // MARK: - Improved Error Handling
                    print("Error checking content blocker state for \(self.contentBlockerExtensionBundleIdentifier): \(error.localizedDescription)")
                    // Update UI to show error state
                    self.popoverViewController.updateStatus(state: .error(error))

                    // MARK: - Future Enhancement: Root Cause Analysis/Logging
                    // If this is a persistent error, log it and potentially trigger
                    // a more in-depth check or guide the user.
                    // Think of 5 potential root causes for SFContentBlockerManager errors:
                    // 1. Incorrect Bundle Identifier: The identifier string doesn't match the extension's actual ID.
                    // 2. Extension Not Found: The extension target might not be built or installed correctly alongside the app.
                    // 3. Safari Not Running or Responsive: Safari might be frozen or not running, preventing communication.
                    // 4. Permissions Issues: System permissions might be preventing the app from querying extension state.
                    // 5. Internal Safari/macOS Error: A system-level issue preventing the API call from succeeding.
                    // Log or present these possibilities to aid debugging/user guidance if the error persists.

                    return
                }

                // Guard against nil state, though the error check above should cover most cases
                guard let state = state else {
                     print("Received nil state but no error when checking \(self.contentBlockerExtensionBundleIdentifier)")
                     // Treat as unknown state or potentially disabled
                     self.popoverViewController.updateStatus(state: .unknown)
                     return
                }

                // Update the popover view controller with the current state
                self.popoverViewController.updateStatus(state: .loaded(isEnabled: state.isEnabled))
            }
        }
    }

    // MARK: - Rule Update Trigger (Conceptual)

    // This function would be called when you want to check for/apply updated rules
    func triggerRuleUpdate() {
         print("Triggering ad rule update...")

         // MARK: - Future Enhancement: Rule Fetching and Compilation
         // 1. Download the latest rule list from a remote source.
         // 2. Validate and parse the downloaded data.
         // 3. Compile the rules into the blockerList.json format.
         // 4. Save the compiled blockerList.json to a shared container accessible by the extension.

         // MARK: - Notifying the Extension (Requires App Group)
         // After saving the updated list to the shared container, you need to tell Safari/the extension
         // to reload the rules. This is done using SFContentBlockerManager.reloadContentBlocker(withIdentifier:).
         // This call must happen on the main application's side, NOT in the extension.

        SFContentBlockerManager.reloadContentBlocker(withIdentifier: contentBlockerExtensionBundleIdentifier) { error in
            DispatchQueue.main.async {
                if let error = error {
                     print("Error reloading content blocker rules: \(error.localizedDescription)")
                     // Update UI to indicate reload failed
                     self.popoverViewController.updateStatus(state: .reloadFailed(error))
                } else {
                     print("Content blocker rules reloaded successfully (assuming new rules were placed in shared container)")
                     // Update UI to indicate reload success
                     // Note: Reloading rules doesn't change the *enabled* state,
                     // but you might update a "Last Updated" timestamp in the UI.
                     // self.popoverViewController.updateStatus(state: .rulesUpdated) // Example state
                }
                 // After attempting reload, re-check the extension state
                 self.checkExtensionState()
            }
        }
    }


    // MARK: - NSApplicationDelegate Optional Methods

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

     // Allow clicking the dock icon to show the window/popover if LSUIElement is true
     // This is less relevant for a status bar app using a popover, but good practice
     // if you had a main window. With LSUIElement=true, clicking the icon doesn't normally
     // activate the app or show windows. The `activate` call in `showPopover` handles this.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            // If no windows are visible, maybe show the popover?
            // Or if you had a main window, show that instead.
            // For a status bar app, just activating is usually sufficient.
             NSApplication.shared.activate(ignoringOtherApps: true)
        }
        return true // Return true to indicate that the app handled the reopen event
    }
}