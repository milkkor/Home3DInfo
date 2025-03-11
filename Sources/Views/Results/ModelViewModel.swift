import SwiftUI
import UniformTypeIdentifiers

class ModelViewModel: ObservableObject {
    @Published var isExporting = false
    @Published var showingAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
    
    func shareModel(url: URL) {
        // Create activity view controller to share file
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        // Present activity view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            DispatchQueue.main.async {
                rootViewController.present(activityVC, animated: true)
            }
        }
    }
} 