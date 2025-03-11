import SwiftUI

struct ScanControlsView: View {
    let isScanning: Bool
    let onStartScan: () -> Void
    let onStopScan: () -> Void
    let onShowModel: () -> Void
    let modelReady: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            // Scan button
            Button(action: isScanning ? onStopScan : onStartScan) {
                HStack {
                    Image(systemName: isScanning ? "stop.fill" : "record.circle")
                    Text(isScanning ? "Stop Scanning" : "Start Scanning")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(isScanning ? Color.red : Color.blue)
                .cornerRadius(15)
                .shadow(radius: 3)
            }
            
            // Show model button (enabled only when model is ready)
            if modelReady {
                Button(action: onShowModel) {
                    HStack {
                        Image(systemName: "cube.box.fill")
                        Text("View Model")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(15)
                    .shadow(radius: 3)
                }
            }
        }
    }
} 