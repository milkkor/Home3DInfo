import UIKit
import ARKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Check if device supports RoomPlan and LiDAR
        checkDeviceCapabilities()
        
        return true
    }
    
    private func checkDeviceCapabilities() {
        // Check if device supports Scene Reconstruction
        if !ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
            print("Warning: This device does not support scene reconstruction")
        }
        
        // Check if LiDAR is available
        if !ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            print("Warning: This device does not have a LiDAR sensor")
        }
    }
} 