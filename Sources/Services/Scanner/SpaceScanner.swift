import RoomPlan
import ARKit
import RealityKit
import Combine

class SpaceScanner: NSObject, ObservableObject {
    // Scanning status
    @Published var isScanning = false
    @Published var scanProgress: Float = 0.0
    @Published var statusMessage = "Ready to start scanning"
    @Published var isModelReady = false
    
    // Core AR and RoomPlan components
    private let roomSession = RoomCaptureSession()
    private let arSession = ARSession()
    private(set) var captureView: RoomCaptureView?
    private(set) var arView = ARView(frame: .zero)
    
    // Scan results
    private(set) var roomResult: CapturedRoom?
    private var meshAnchors: [ARMeshAnchor] = []
    private(set) var combinedModel: AnchorEntity?
    
    // Processors
    private let meshProcessor = MeshProcessor()
    
    override init() {
        super.init()
        setupSessions()
    }
    
    private func setupSessions() {
        // Setup RoomCapture
        roomSession.delegate = self
        
        // Setup ARView
        arView.environment.sceneUnderstanding.options = [.occlusion, .physics]
        
        // Create CaptureView
        captureView = RoomCaptureView(frame: .zero, session: roomSession)
    }
    
    func startScanning() {
        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        config.sceneReconstruction = .meshWithClassification
        config.planeDetection = [.horizontal, .vertical]
        
        // Start session
        arSession.delegate = self
        arSession.run(config)
        
        // Associate AR session and start RoomPlan
        roomSession.arSession = arSession
        
        let roomConfig = RoomCaptureSession.Configuration()
        roomSession.run(configuration: roomConfig)
        
        isScanning = true
        statusMessage = "Scanning environment..."
    }
    
    func stopScanning() {
        roomSession.stop()
        isScanning = false
        statusMessage = "Scan completed, processing..."
    }
    
    // Process and integrate scan results
    private func processScanResults() {
        guard let room = roomResult else { return }
        
        statusMessage = "Generating 3D model..."
        
        // Process in background to avoid UI lag
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Generate integrated model
            self.combinedModel = self.meshProcessor.combineRoomAndMesh(
                room: room, 
                meshAnchors: self.meshAnchors
            )
            
            // Update UI state
            DispatchQueue.main.async {
                self.arView.scene.anchors.removeAll()
                if let model = self.combinedModel {
                    self.arView.scene.addAnchor(model)
                }
                self.statusMessage = "3D model generation complete"
                self.isModelReady = true
            }
        }
    }
    
    // Export model
    func exportModel(completion: @escaping (URL?, Error?) -> Void) {
        guard let room = roomResult else {
            completion(nil, NSError(domain: "SpaceScanner", code: 1, userInfo: [NSLocalizedDescriptionKey: "No scan results available"]))
            return
        }
        
        let exporter = ModelExporter()
        exporter.exportModel(room: room, meshAnchors: meshAnchors, completion: completion)
    }
}

// MARK: - ARSessionDelegate
extension SpaceScanner: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        let newMeshAnchors = anchors.compactMap { $0 as? ARMeshAnchor }
        meshAnchors.append(contentsOf: newMeshAnchors)
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let meshAnchor = anchor as? ARMeshAnchor {
                if let index = meshAnchors.firstIndex(where: { $0.identifier == meshAnchor.identifier }) {
                    meshAnchors[index] = meshAnchor
                } else {
                    meshAnchors.append(meshAnchor)
                }
            }
        }
    }
}

// MARK: - RoomCaptureSessionDelegate
extension SpaceScanner: RoomCaptureSessionDelegate {
    private func captureSession(_ session: RoomCaptureSession, didUpdate progress: Float) {
        scanProgress = progress
    }
    
    func captureSession(_ session: RoomCaptureSession, didEndWith result: CapturedRoom, error: Error?) {
        if let error = error {
            statusMessage = "Scan error: \(error.localizedDescription)"
            return
        }
        
        roomResult = result
        processScanResults()
    }
} 
