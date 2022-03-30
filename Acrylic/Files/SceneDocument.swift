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

class SceneDocument: UIDocument, ObservableObject {
    struct Object: Identifiable, Codable, Hashable {
        enum Shape: Codable, Hashable {
            case plane
            case sphere
            case cube(chamferEdges: Float = 0)
            case pyramid
            case custom(fileUrl: URL)
        }
        
        var id: UUID = UUID()
        var shape: Shape
        var material: Material
        
        var position: Vector3 = .zero
        var rotation: Vector4 = .zero
        var eulerAngles: Vector3 = .zero
        var scale: Vector3 = .init(x: 1, y: 1, z: 1)
    }
    
    struct Camera: Identifiable, Codable, Hashable {
        var id: UUID = UUID()
        var position: Vector3 = .zero
        var rotation: Vector4 = .zero
        var eulerAngles: Vector3 = .zero
        var scale: Vector3 = .init(x: 1, y: 1, z: 1)
        
        var screenSpaceAmbientOcclusionOptions: ScreenSpaceAmbientOcclusionOptions = .init()
        var depthOfFieldOptions: DepthOfFieldOptions = .init()
        var bloomOptions: BloomOptions = .init()
        
        var colorFringeOptions: ColorFringeOptions = .init()
        
        var useHDR: Bool = false
        var useAutoExposure: Bool = false
    }
    
    struct Light: Identifiable, Codable, Hashable {
        enum LightType: Codable, Hashable {
            case directional
            case omni
            case ambient
            case area
            case spot
        }
        
        var id: UUID = UUID()
        
        var lightType: LightType
        var intensity: Float = 1
        var color: Color = .init(uiColor: .white)
        
        var castsShadow: Bool = true
        
        var position: Vector3 = .zero
        var rotation: Vector4 = .zero
        var eulerAngles: Vector3 = .zero
        var scale: Vector3 = .init(x: 1, y: 1, z: 1)
    }
    
    struct Vector2: Codable, Hashable {
        var x: Float
        var y: Float
        
        static var zero: Self = .init(x: 0, y: 0)
    }
    
    struct Vector3: Codable, Hashable {
        var x: Float
        var y: Float
        var z: Float
        
        static var zero: Self = .init(x: 0, y: 0, z: 0)
    }
    
    struct Vector4: Codable, Hashable {
        var x: Float
        var y: Float
        var z: Float
        var w: Float
        
        static var zero: Self = .init(x: 0, y: 0, z: 0, w: 0)
    }
    
    struct Material: Codable, Hashable {
        var color: Color = .init(uiColor: UIColor.white)
        var emmission: Float = 0
        var roughness: Float = 1
    }
    
    struct Color: Codable, Hashable {
        var red : CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
        
        var uiColor : UIColor {
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
        
        init(uiColor : UIColor) {
            uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
    }
    
    struct ScreenSpaceReflectionsOptions: Codable, Hashable {
        var isEnabled: Bool = false
        var sampleCount: Int = 64
        var maxDistance: Float = 128
    }
    
    struct ScreenSpaceAmbientOcclusionOptions: Codable, Hashable {
        var isEnabled: Bool = false
        var intensity: Float = 1
    }
    
    struct DepthOfFieldOptions: Codable, Hashable {
        var isEnabled: Bool = false
        var focusDistance: Float = 6
        var fStop: Float = 0.1
        var focalLength: Float = 16
    }
    
    struct ColorFringeOptions: Codable, Hashable {
        var isEnabled: Bool = false
        var strength: Float = 0.8
        var intensity: Float = 0.8
    }
    
    struct BloomOptions: Codable, Hashable {
        var isEnabled: Bool = false
        var intensity: Float = 1.5
    }
    
    struct RaytracingOptions: Codable, Hashable {
        var isEnabled: Bool = false
    }
    
    enum Antialiasing: Codable, Hashable {
        case none
        case multisampling2X
        case multisampling4X
        case multisampling8X
        case multisampling16X
    }
    
    @Published var cameras: Set<Camera> = [.init()]
    
    @Published var objects: Set<Object> = []
    @Published var lights: Set<Light> = []
    @Published var backgroundColor: Color = .init(uiColor: .white)
    
    @Published var antialiasing: Antialiasing = .none
    
    @Published var raytracingOptions: RaytracingOptions = .init()
    @Published var screenSpaceReflectionsOptions: ScreenSpaceReflectionsOptions = .init()
    
    var previewImage: Data? = nil
    
    private struct SceneDescriptorModel: Codable {
        var cameras: Set<Camera>
        
        var objects: Set<Object>
        var lights: Set<Light>
        var backgroundColor: Color
        
        var antialiasing: Antialiasing
        
        var raytracingOptions: RaytracingOptions
        var screenSpaceReflectionsOptions: ScreenSpaceReflectionsOptions
        
        init(_ document: SceneDocument) {
            self.cameras = document.cameras
            
            self.objects = document.objects
            self.lights = document.lights
            self.backgroundColor = document.backgroundColor
            
            self.antialiasing = document.antialiasing
            
            self.raytracingOptions = document.raytracingOptions
            self.screenSpaceReflectionsOptions = document.screenSpaceReflectionsOptions
        }
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let topFileWrapper = contents as? FileWrapper,
              let compressedSceneDescriptor = topFileWrapper.fileWrappers?["SceneDescriptor"]?.regularFileContents as? NSData else {
            return
        }
        
        let decompressedSceneDescriptor = try compressedSceneDescriptor.decompressed(using: .zlib) as Data
        let sceneDescriptor = try JSONDecoder().decode(SceneDescriptorModel.self, from: decompressedSceneDescriptor)
        
        self.cameras = sceneDescriptor.cameras
        self.lights = sceneDescriptor.lights
        self.backgroundColor = sceneDescriptor.backgroundColor
        
        self.antialiasing = sceneDescriptor.antialiasing
        
        self.raytracingOptions = sceneDescriptor.raytracingOptions
        self.screenSpaceReflectionsOptions = sceneDescriptor.screenSpaceReflectionsOptions
        
        self.previewImage = topFileWrapper.fileWrappers?["PreviewImage"]?.regularFileContents
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
