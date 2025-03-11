import RoomPlan
import ARKit
import RealityKit

class ModelExporter {
    func exportModel(room: CapturedRoom, meshAnchors: [ARMeshAnchor], completion: @escaping (URL?, Error?) -> Void) {
        // Create temporary file URL
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("SpaceScan_\(Date().timeIntervalSince1970).usdz")
        
        do {
            // Use RoomPlan's export functionality
            try room.export(to: tempURL) { object in
                // Find corresponding detailed mesh
                let meshProcessor = MeshProcessor()
                if let entity = meshProcessor.findAndCreateMeshFor(object: object, from: meshAnchors) {
                    return entity
                }
                
                // Fallback when no detailed mesh is available
                let material = SimpleMaterial(color: .gray, roughness: 0.5, isMetallic: false)
                return ModelEntity(mesh: MeshResource.generateBox(size: object.dimensions), materials: [material])
            }
            
            completion(tempURL, nil)
        } catch {
            completion(nil, error)
        }
    }
} 