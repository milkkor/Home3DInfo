import SwiftUI
import RealityKit

struct ModelView: View {
    let scanner: SpaceScanner
    @StateObject private var viewModel = ModelViewModel()
    
    var body: some View {
        VStack {
            // Title
            Text("3D Model Preview")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            // 3D model preview
            ModelARViewRepresentable(scanner: scanner)
                .edgesIgnoringSafeArea(.horizontal)
                .frame(maxHeight: .infinity)
            
            // Controls and export
            ModelExportView(
                isExporting: $viewModel.isExporting,
                onExport: { exportModel() }
            )
            .padding()
        }
        .alert(isPresented: $viewModel.showingAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func exportModel() {
        viewModel.isExporting = true
        scanner.exportModel { url, error in
            viewModel.isExporting = false
            
            if let error = error {
                viewModel.showAlert(title: "Export Failed", message: error.localizedDescription)
                return
            }
            
            guard let url = url else {
                viewModel.showAlert(title: "Export Failed", message: "Failed to generate model file")
                return
            }
            
            viewModel.shareModel(url: url)
        }
    }
}

struct ModelARViewRepresentable: UIViewRepresentable {
    let scanner: SpaceScanner
    
    func makeUIView(context: Context) -> ARView {
        return scanner.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Update view
    }
} 