import SwiftUI
import Combine

class ScanningViewModel: ObservableObject {
    // Scanner service
    let scanner = SpaceScanner()
    
    // UI state
    @Published var showingModel = false
    @Published var showingError = false
    @Published var errorMessage = ""
    
    // Cancellable collection
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        // Monitor errors and status changes
    }
    
    // Scan controls
    func startScanning() {
        scanner.startScanning()
    }
    
    func stopScanning() {
        scanner.stopScanning()
    }
    
    func showModel() {
        showingModel = true
    }
} 