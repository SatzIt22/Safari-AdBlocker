import Cocoa
import SafariServices

// Define possible states for the UI to display
enum AdBlockerStatus {
    case checking
    case loaded(isEnabled: Bool)
    case error(Error)
    case unknown // For cases like nil state without error
    case reloadFailed(Error) // If rule reload fails
    case rulesUpdated // Example state for successful rule update

    var description: String {
        switch self {
        case .checking: return "Checking status..."
        case .loaded(let isEnabled): return isEnabled ? "Ad Blocker is Enabled" : "Ad Blocker is Disabled"
        case .error(let err): return "Error: \(err.localizedDescription)"
        case .unknown: return "Unknown Status"
        case .reloadFailed(let err): return "Rule update failed: \(err.localizedDescription)"
        case .rulesUpdated: return "Rules updated successfully"
        }
    }

    var textColor: NSColor {
        switch self {
        case .checking, .unknown: return .secondaryLabelColor
        case .loaded(let isEnabled): return isEnabled ? .systemGreen : .systemRed
        case .error, .reloadFailed: return .systemRed
        case .rulesUpdated: return .systemGreen
        }
    }
}


class StatusPopoverViewController: NSViewController {

    // UI Elements
    private var statusLabel: NSTextField!
    private var enableButton: NSButton!
    private var updateRulesButton: NSButton! // Add a button to trigger updates

    // Weak reference back to the status item for positioning
    weak var statusItem: NSStatusItem?

    // MARK: - View Lifecycle

    override func loadView() {
        // Define the size for the popover content
        let contentRect = NSRect(x: 0, y: 0, width: 350, height: 250) // Adjust size as needed
        self.view = NSView(frame: contentRect)
        setupUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Any additional setup after loading the view, if needed.
    }

    // MARK: - UI Setup

    private func setupUI() {
        // Add visual effect view for background blurring (optional, but common for popovers)
        let visualEffectView = NSVisualEffectView()
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.material = .popover // Or another appropriate material
        visualEffectView.state = .active
        view.addSubview(visualEffectView)
        NSLayoutConstraint.activate([
            visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])


        // Title
        let titleLabel = NSTextField(labelWithString: "Safari Ad Blocker")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 16) // Slightly smaller for popover
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Status Label
        statusLabel = NSTextField(labelWithString: AdBlockerStatus.checking.description)
        statusLabel.textColor = AdBlockerStatus.checking.textColor
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)

        // Enable Button (Open Safari Settings)
        enableButton = NSButton(title: "Open Safari Settings...", target: self, action: #selector(openSafariPreferences))
        enableButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(enableButton)

         // MARK: - Future Enhancement: Update Rules Button
        updateRulesButton = NSButton(title: "Update Ad Rules", target: self, action: #selector(triggerRuleUpdateAction))
        updateRulesButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(updateRulesButton)
        // Initially hide this button or disable it until update logic is ready
        // updateRulesButton.isHidden = true


        // Instructions
        let instructionsText = """
        To enable Ad Blocker:

        1. Click "Open Safari Settings..."
        2. Go to the Extensions tab.
        3. Check the box next to "Safari Ad Blocker".
        4. (Optional) Check "Private Browse" for additional protection.
        """

        let instructionsLabel = NSTextField(wrappingLabelWithString: instructionsText)
        instructionsLabel.font = NSFont.systemFont(ofSize: 11) // Smaller font for instructions
        instructionsLabel.textColor = .secondaryLabelColor // Less prominent color
        instructionsLabel.isSelectable = false // Make text non-selectable
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionsLabel)


        // Layout constraints - Use a stack view or just constraints as before
        // Using constraints directly for this simple layout
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Status Label
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Enable Button
            enableButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            enableButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

             // Update Rules Button
            updateRulesButton.topAnchor.constraint(equalTo: enableButton.bottomAnchor, constant: 8), // Space between buttons
            updateRulesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Instructions
            instructionsLabel.topAnchor.constraint(equalTo: updateRulesButton.bottomAnchor, constant: 20), // Space after buttons
            instructionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            instructionsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            // Keep instructions from going off the bottom (optional, adjust popover height)
            instructionsLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Actions

    @objc private func openSafariPreferences() {
        // Close the popover before opening preferences for a cleaner transition
        if let popover = self.view.window?.contentViewController?.representedObject as? NSPopover {
             popover.performClose(nil)
        }
        // Use the specific extensions URL scheme
        if let settingsURL = URL(string: "x-apple.systempreferences:com.apple.Safari.ExtensionsPreference.extension") {
            NSWorkspace.shared.open(settingsURL)
        } else {
            // Fallback to general Safari preferences if the specific URL fails
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.Safari")!)
        }

    }

     @objc private func triggerRuleUpdateAction() {
        print("Update rules button tapped")
        // Delegate the update trigger to the AppDelegate or a dedicated manager
        // Find the AppDelegate instance and call the update method
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.triggerRuleUpdate()
        }
         // Optionally update UI to indicate update is in progress
         updateStatus(state: .checking) // or a specific updating state
     }


    // MARK: - Status Update

    func updateStatus(state: AdBlockerStatus) {
        statusLabel.stringValue = state.description
        statusLabel.textColor = state.textColor

        // Adjust UI based on state if needed (e.g., disable buttons)
        // Example: Disable update button if an update is already in progress or failed
        // updateRulesButton.isEnabled = !(state == .checking || state == .reloadFailed(...))
    }
}