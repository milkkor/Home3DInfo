import SwiftUI

@main
struct ScannerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ScanView()
        }
    }
} 