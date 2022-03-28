//
//  SceneDocument.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/27/22.
//

import UIKit

class SceneDocument: UIDocument {
    struct Object: Codable {
        enum Shape: Codable {
            case plane
            case sphere
            case cube(chamferEdges: Float = 0)
            case pyramid
            case custom(fileUrl: URL)
        }
        
        var shape: Shape
        var material: Material
        
        var position: Vector3 = .zero
        var rotation: Vector4 = .zero
        var eulerAngles: Vector3 = .zero
        var scale: Vector3 = .init(x: 1, y: 1, z: 1)
    }
    
    struct Camera: Codable {
        var position: Vector3 = .zero
        var rotation: Vector4 = .zero
        var eulerAngles: Vector3 = .zero
        var scale: Vector3 = .init(x: 1, y: 1, z: 1)
    }
    
    struct Light: Codable {
        enum LightType: Codable {
            case directional
            case omni
            case ambient
            case area
        }
        
        var lightType: LightType
        var intensity: Float
        var color: Color
        
        var position: Vector3 = .zero
        var rotation: Vector4 = .zero
        var eulerAngles: Vector3 = .zero
        var scale: Vector3 = .init(x: 1, y: 1, z: 1)
    }
    
    struct Vector2: Codable {
        var x: Float
        var y: Float
        
        static var zero: Self = .init(x: 0, y: 0)
    }
    
    struct Vector3: Codable {
        var x: Float
        var y: Float
        var z: Float
        
        static var zero: Self = .init(x: 0, y: 0, z: 0)
    }
    
    struct Vector4: Codable {
        var x: Float
        var y: Float
        var z: Float
        var w: Float
        
        static var zero: Self = .init(x: 0, y: 0, z: 0, w: 0)
    }
    
    struct Material: Codable {
        var color: Color = .init(uiColor: UIColor.white)
        var emmission: Float = 0
        var roughness: Float = 1
    }
    
    struct Color: Codable {
        var red : CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
        
        var uiColor : UIColor {
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
        
        init(uiColor : UIColor) {
            uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
    }
    
    struct ScreenSpaceReflectionsOptions: Codable {
        var isEnabled: Bool = false
        var sampleCount: Int = 64
        var maxDistance: Int = 128
    }
    
    struct ScreenSpaceAmbientOcclusionOptions: Codable {
        var isEnabled: Bool = false
        var intensity: Int = 1
    }
    
    struct DepthOfFieldOptions: Codable {
        var isEnabled: Bool = false
        var focusDistance: Float = 6
        var fStop: Float = 0.1
        var focalLength: Float = 16
    }
    
    struct ColorFringeOptions: Codable {
        var isEnabled: Bool = false
        var strength: Float = 0.8
        var intensity: Float = 0.8
    }
    
    struct RaytracingOptions: Codable {
        var isEnabled: Bool = false
    }
    
    enum Antialiasing: Codable {
        case none
        case multisampling2X
        case multisampling4X
        case multisampling8X
        case multisampling16X
    }
    
    var camera: Camera = .init()
    
    var objects: [Object] = []
    var lights: [Light] = []
    var backgroundColor: Color = .init(uiColor: .white)
    
    var useHDR: Bool = false
    var useAutoExposure: Bool = false
    var antialiasing: Antialiasing = .none
    var depthOfFieldOptions: DepthOfFieldOptions = .init()
    
    var raytracingOptions: RaytracingOptions = .init()
    var screenSpaceReflectionsOptions: ScreenSpaceReflectionsOptions = .init()
}
