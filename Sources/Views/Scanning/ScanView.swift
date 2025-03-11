import SwiftUI
import RoomPlan
import ARKit

struct ScanView: View {
    @StateObject private var viewModel = ScanningViewModel()
    
    var body: some View {
        ZStack {
            // Background scanning view
            ScannerRepresentable(scanner: viewModel.scanner)
                .edgesIgnoringSafeArea(.all)
            
            // Scanning control UI
            VStack {
                Spacer()
                
                // Scan status
                ScanStatusView(
                    progress: viewModel.scanner.scanProgress,
                    statusMessage: viewModel.scanner.statusMessage
                )
                .padding()
                
                // Control buttons
                ScanControlsView(
                    isScanning: viewModel.scanner.isScanning,
                    onStartScan: viewModel.startScanning,
                    onStopScan: viewModel.stopScanning,
                    onShowModel: viewModel.showModel,
                    modelReady: viewModel.scanner.isModelReady
                )
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $viewModel.showingModel) {
            ModelView(scanner: viewModel.scanner)
        }
        .alert(isPresented: $viewModel.showingError) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct ScannerRepresentable: UIViewControllerRepresentable {
    let scanner: SpaceScanner
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        return ScannerViewController(scanner: scanner)
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        // Update controller
    }
}

class ScannerViewController: UIViewController {
    private let scanner: SpaceScanner
    
    init(scanner: SpaceScanner) {
        self.scanner = scanner
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add RoomCaptureView
        if let captureView = scanner.captureView {
            captureView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(captureView)
            NSLayoutConstraint.activate([
                captureView.topAnchor.constraint(equalTo: view.topAnchor),
                captureView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                captureView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                captureView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }
} 