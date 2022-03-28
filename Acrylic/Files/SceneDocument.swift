//
//  SceneDocument.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/27/22.
//

import UIKit
import UniformTypeIdentifiers

extension UTType {
    static var acrylicScene: UTType {
        UTType(importedAs: "com.acrylic.scene")
    }
}

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
    var screenSpaceAmbientOcclusionOptions: ScreenSpaceAmbientOcclusionOptions = .init()
    
    var colorFringeOptions: ColorFringeOptions = .init()
    
    var previewImage: Data? = nil
    
    private struct SceneDescriptorModel: Codable {
        var camera: Camera
        
        var objects: [Object]
        var lights: [Light]
        var backgroundColor: Color
        
        var useHDR: Bool
        var useAutoExposure: Bool
        var antialiasing: Antialiasing
        var depthOfFieldOptions: DepthOfFieldOptions
        
        var raytracingOptions: RaytracingOptions
        var screenSpaceReflectionsOptions: ScreenSpaceReflectionsOptions
        var screenSpaceAmbientOcclusionOptions: ScreenSpaceAmbientOcclusionOptions
        
        var colorFringeOptions: ColorFringeOptions
        
        init(_ document: SceneDocument) {
            self.camera = document.camera
            
            self.objects = document.objects
            self.lights = document.lights
            self.backgroundColor = document.backgroundColor
            
            self.useHDR = document.useHDR
            self.useAutoExposure = document.useAutoExposure
            self.antialiasing = document.antialiasing
            self.depthOfFieldOptions = document.depthOfFieldOptions
            
            self.raytracingOptions = document.raytracingOptions
            self.screenSpaceReflectionsOptions = document.screenSpaceReflectionsOptions
            self.screenSpaceAmbientOcclusionOptions = document.screenSpaceAmbientOcclusionOptions
            
            self.colorFringeOptions = document.colorFringeOptions
        }
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let topFileWrapper = contents as? FileWrapper,
              let compressedSceneDescriptor = topFileWrapper.fileWrappers?["SceneDescriptor"]?.regularFileContents as? NSData else {
            return
        }
        
        let decompressedSceneDescriptor = try compressedSceneDescriptor.decompressed(using: .zlib) as Data
        let sceneDescriptor = try JSONDecoder().decode(SceneDescriptorModel.self, from: decompressedSceneDescriptor)
        
        self.camera = sceneDescriptor.camera
        self.lights = sceneDescriptor.lights
        self.backgroundColor = sceneDescriptor.backgroundColor
        
        self.useHDR = sceneDescriptor.useHDR
        self.useAutoExposure = sceneDescriptor.useAutoExposure
        self.antialiasing = sceneDescriptor.antialiasing
        self.depthOfFieldOptions = sceneDescriptor.depthOfFieldOptions
        
        self.raytracingOptions = sceneDescriptor.raytracingOptions
        self.screenSpaceReflectionsOptions = sceneDescriptor.screenSpaceReflectionsOptions
        self.screenSpaceAmbientOcclusionOptions = sceneDescriptor.screenSpaceAmbientOcclusionOptions
        
        self.colorFringeOptions = sceneDescriptor.colorFringeOptions
        
        self.previewImage = topFileWrapper.fileWrappers?["PreviewImage.heic"]?.regularFileContents
    }
    
    override func contents(forType typeName: String) throws -> Any {
        let sceneDescriptor = SceneDescriptorModel(self)
        let sceneDescriptorJSON = try JSONEncoder().encode(sceneDescriptor)
        let compressedSceneDescriptor = try (sceneDescriptorJSON as NSData).compressed(using: .zlib)
        let sceneDescriptorFile = FileWrapper(regularFileWithContents: compressedSceneDescriptor as Data)
        sceneDescriptorFile.preferredFilename = "SceneDescriptor"
        
        var fileWrappers: [String: FileWrapper] = ["SceneDescriptor": sceneDescriptorFile]
        
        if let previewImage = previewImage {
            let previewImageFile = FileWrapper(regularFileWithContents: previewImage)
            fileWrappers["PreviewImage"] = previewImageFile
        }
        return FileWrapper(directoryWithFileWrappers: fileWrappers)
    }
}
