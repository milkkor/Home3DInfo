import RoomPlan
import ARKit
import RealityKit

class MeshProcessor {
    // Combine RoomPlan and ARKit mesh data
    func combineRoomAndMesh(room: CapturedRoom, meshAnchors: [ARMeshAnchor]) -> AnchorEntity {
        let rootAnchor = AnchorEntity()
        
        // Add structural elements (walls, floors, etc.)
        addStructuralElements(to: rootAnchor, from: room)
        
        // Add furniture and objects
        addFurnitureWithMeshes(to: rootAnchor, from: room, meshAnchors: meshAnchors)
        
        return rootAnchor
    }
    
    // Add structural elements
    private func addStructuralElements(to parent: AnchorEntity, from room: CapturedRoom) {
        // Process walls
        for wall in room.walls {
            let material = SimpleMaterial(color: .lightGray, roughness: 0.5, isMetallic: false)
            let entity = ModelEntity(mesh: generateMeshFor(surface: wall), materials: [material])
            entity.transform = Transform(matrix: wall.transform)
            parent.addChild(entity)
        }
        
        // Process floors
        for floor in room.floors {
            let material = SimpleMaterial(color: .sand, roughness: 0.3, isMetallic: false)
            let entity = ModelEntity(mesh: generateMeshFor(surface: floor), materials: [material])
            entity.transform = Transform(matrix: floor.transform)
            parent.addChild(entity)
        }
        
        // Process ceilings
        for ceiling in room.openings where ceiling.category == .ceiling {
            let material = SimpleMaterial(color: .white, roughness: 0.3, isMetallic: false)
            let entity = ModelEntity(mesh: generateMeshFor(surface: ceiling), materials: [material])
            entity.transform = Transform(matrix: ceiling.transform)
            parent.addChild(entity)
        }
        
        // Process doors and windows
        for door in room.doors {
            let material = SimpleMaterial(color: .brown, roughness: 0.3, isMetallic: false)
            let entity = ModelEntity(mesh: generateMeshFor(surface: door), materials: [material])
            entity.transform = Transform(matrix: door.transform)
            parent.addChild(entity)
        }
        
        for window in room.windows {
            let material = SimpleMaterial(color: .lightBlue.withAlphaComponent(0.7), roughness: 0.1, isMetallic: true)
            let entity = ModelEntity(mesh: generateMeshFor(surface: window), materials: [material])
            entity.transform = Transform(matrix: window.transform)
            parent.addChild(entity)
        }
    }
    
    // Add furniture with detailed meshes
    private func addFurnitureWithMeshes(to parent: AnchorEntity, from room: CapturedRoom, meshAnchors: [ARMeshAnchor]) {
        for object in room.objects {
            // Try to find detailed mesh
            if let meshEntity = findAndCreateMeshFor(object: object, from: meshAnchors) {
                meshEntity.transform = Transform(matrix: object.transform)
                parent.addChild(meshEntity)
            } else {
                // Use basic shape if no detailed mesh found
                let material = getMaterialForObjectCategory(object.category)
                let entity = ModelEntity(mesh: MeshResource.generateBox(size: object.dimensions), materials: [material])
                entity.transform = Transform(matrix: object.transform)
                parent.addChild(entity)
            }
        }
    }
    
    // Generate mesh for surface
    private func generateMeshFor(surface: CapturedRoom.Surface) -> MeshResource {
        return MeshResource.generatePlane(width: surface.dimensions.x, 
                                         depth: surface.dimensions.z)
    }
    
    // Create detailed mesh for object
    func findAndCreateMeshFor(object: CapturedRoom.Object, from meshAnchors: [ARMeshAnchor]) -> ModelEntity? {
        let objectCenter = object.transform.translation
        let halfSize = object.dimensions / 2
        let expandedSize = halfSize * 1.2 // Expand search range
        
        // Collect mesh anchors that overlap with the object
        var relevantAnchors: [(anchor: ARMeshAnchor, relevance: Float)] = []
        
        for anchor in meshAnchors {
            let vertices = anchor.geometry.vertices.buffer.contents().assumingMemoryBound(to: SIMD3<Float>.self)
            let vertexCount = anchor.geometry.vertices.count
            
            var pointsInBounds = 0
            for i in 0..<vertexCount {
                let vertex = vertices[i]
                if abs(vertex.x - objectCenter.x) <= expandedSize.x &&
                   abs(vertex.y - objectCenter.y) <= expandedSize.y &&
                   abs(vertex.z - objectCenter.z) <= expandedSize.z {
                    pointsInBounds += 1
                }
            }
            
            let relevance = Float(pointsInBounds) / Float(vertexCount)
            if relevance > 0.1 { // At least 10% of points within boundaries
                relevantAnchors.append((anchor, relevance))
            }
        }
        
        // Return nil if no relevant meshes found
        if relevantAnchors.isEmpty {
            return nil
        }
        
        // Select the most relevant mesh
        relevantAnchors.sort { $0.relevance > $1.relevance }
        let bestAnchor = relevantAnchors[0].anchor
        
        // Create mesh resource from mesh anchor
        do {
            var descriptor = MeshDescriptor()
            let vertices = bestAnchor.geometry.vertices.buffer.contents().assumingMemoryBound(to: SIMD3<Float>.self)
            descriptor.positions = MeshBuffers.Positions(vertices, count: bestAnchor.geometry.vertices.count)
            
            let faces = bestAnchor.geometry.faces.buffer.contents().assumingMemoryBound(to: Int32.self)
            descriptor.primitives = .triangles(faces, count: bestAnchor.geometry.faces.count)
            
            if bestAnchor.geometry.normals.count > 0 {
                let normals = bestAnchor.geometry.normals.buffer.contents().assumingMemoryBound(to: SIMD3<Float>.self)
                descriptor.normals = MeshBuffers.Normals(normals, count: bestAnchor.geometry.normals.count)
            }
            
            let meshResource = try MeshResource.generate(from: [descriptor])
            let material = getMaterialForObjectCategory(object.category)
            return ModelEntity(mesh: meshResource, materials: [material])
            
        } catch {
            print("Error creating mesh resource: \(error)")
            return nil
        }
    }
    
    // Get appropriate material based on object category
    private func getMaterialForObjectCategory(_ category: CapturedRoom.Object.Category) -> Material {
        switch category {
        case .storage, .cabinet, .refrigerator:
            return SimpleMaterial(color: .darkGray, roughness: 0.2, isMetallic: true)
        case .bed:
            return SimpleMaterial(color: .blue, roughness: 0.7, isMetallic: false)
        case .table, .desk:
            return SimpleMaterial(color: .brown, roughness: 0.5, isMetallic: false)
        case .chair, .sofa, .couch:
            return SimpleMaterial(color: .darkGreen, roughness: 0.8, isMetallic: false)
        case .toilet, .bathtub, .sink:
            return SimpleMaterial(color: .white, roughness: 0.1, isMetallic: true)
        case .television:
            return SimpleMaterial(color: .black, roughness: 0.1, isMetallic: true)
        case .staircase:
            return SimpleMaterial(color: .gray, roughness: 0.4, isMetallic: false)
        default:
            return SimpleMaterial(color: .lightGray, roughness: 0.5, isMetallic: false)
        }
    }
} 