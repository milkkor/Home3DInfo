import SwiftUI

struct ModelExportView: View {
    @Binding var isExporting: Bool
    let onExport: () -> Void
    
    var body: some View {
        Button(action: onExport) {
            HStack {
                if isExporting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "square.and.arrow.up")
                }
                Text(isExporting ? "Exporting..." : "Export Model")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 200)
            .background(isExporting ? Color.gray : Color.blue)
            .cornerRadius(10)
            .shadow(radius: 3)
        }
        .disabled(isExporting)
    }
} 