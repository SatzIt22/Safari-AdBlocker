import Foundation
import SafariServices // Import SafariServices

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {
    func beginRequest(with context: NSExtensionContext) {
        // Attempt to find the blockerList.json file in the extension's bundle.
        guard let url = Bundle.main.url(forResource: "blockerList", withExtension: "json") else {
            // Log an error if the file is not found
            print("Error: blockerList.json not found in the extension bundle.")
            // Complete the request with an error or empty list if necessary
            context.completeRequest(returningItems: [], completionHandler: nil)
            return
        }

        let attachment = NSItemProvider(contentsOf: url)! // Force unwrap is safer now after the guard
        let item = NSExtensionItem()
        item.attachments = [attachment]

        // Complete the request, providing the attachment with the JSON file.
        context.completeRequest(returningItems: [item], completionHandler: nil)

        // MARK: - Future Enhancement: Load from Shared Container
        // If implementing dynamic updates via a shared container (App Group),
        // you would check the shared container path first for the latest version
        // of blockerList.json before falling back to the bundled version.
        // Example conceptual code:
        /*
        if let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "YOUR_APP_GROUP_ID") {
             let sharedJsonURL = sharedContainerURL.appendingPathComponent("blockerList.json")
             if FileManager.default.fileExists(atPath: sharedJsonURL.path) {
                 // Load from shared container
                 let attachment = NSItemProvider(contentsOf: sharedJsonURL)!
                 let item = NSExtensionItem()
                 item.attachments = [attachment]
                 context.completeRequest(returningItems: [item], completionHandler: nil)
                 return // Request completed
             }
         }
         // Fallback to bundled version if shared container version doesn't exist or can't be accessed
         guard let url = Bundle.main.url(forResource: "blockerList", withExtension: "json") else { ... } // Existing logic
         */
    }
}