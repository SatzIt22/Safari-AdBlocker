import Cocoa
import SafariServices

class MainViewController: NSViewController {
    private var statusLabel: NSTextField!
    private var enableButton: NSButton!
    
    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 300))
        setupUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setupUI() {
        // Title
        let titleLabel = NSTextField(labelWithString: "Safari Ad Blocker")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 18)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Status Label
        statusLabel = NSTextField(labelWithString: "Checking status...")
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        // Enable Button
        enableButton = NSButton(title: "Open Safari Settings", target: self, action: #selector(openSafariPreferences))
        enableButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(enableButton)
        
        // Instructions
        let instructionsText = """
        To enable ad blocking in Private Browsing:
        
        1. Click "Open Safari Settings"
        2. Go to Extensions tab
        3. Enable this extension
        4. Check "Private Browsing" option
        
        The extension will block ads in both normal and private browsing modes.
        """
        
        let instructionsLabel = NSTextField(wrappingLabelWithString: instructionsText)
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionsLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            enableButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            enableButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            instructionsLabel.topAnchor.constraint(equalTo: enableButton.bottomAnchor, constant: 20),
            instructionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func openSafariPreferences() {
        NSWorkspace.shared.open(URL(string: "safari-settings://extensions")!)
    }
    
    func updateStatus(enabled: Bool) {
        statusLabel.stringValue = enabled ? "Ad Blocker is enabled" : "Ad Blocker is disabled"
        statusLabel.textColor = enabled ? NSColor.systemGreen : NSColor.systemRed
    }
}
