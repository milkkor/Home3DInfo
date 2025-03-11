import SwiftUI

struct ScanStatusView: View {
    let progress: Float
    let statusMessage: String
    
    var body: some View {
        VStack(spacing: 10) {
            Text(statusMessage)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(8)
                .background(Color.black.opacity(0.6))
                .cornerRadius(8)
            
            if progress > 0 && progress < 1 {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(width: 250)
                    .accentColor(.blue)
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(8)
            }
        }
    }
} 