//
//  SceneDocument.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/27/22.
//

import UIKit
import UniformTypeIdentifiers
import DifferenceKit
import RandomColor

extension UTType {
    static var acrylicScene: UTType {
        UTType(importedAs: "com.acrylic.scene")
    }
}

class SceneDocument: UIDocument, ObservableObject {
    class Object: Identifiable, Codable, Hashable, Differentiable {
        static func == (lhs: SceneDocument.Object, rhs: SceneDocument.Object) -> Bool {
            return lhs.id == rhs.id && lhs.shape == rhs.shape && lhs.material == rhs.material && lhs.position == rhs.position && lhs.rotation == rhs.rotation && lhs.eulerAngles == rhs.eulerAngles && lhs.scale == rhs.scale
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(shape)
            hasher.combine(material)
            hasher.combine(position)
            hasher.combine(rotation)
            hasher.combine(eulerAngles)
            hasher.combine(scale)
        }
        
        enum Shape: Codable, Hashable, Differentiable {
            case plane
            case sphere(segmentCount: Int = 32)
            case cube(chamferEdges: Float = 0, segmentCount: Int = 4)
            case pyramid
            case custom(fileUrl: URL)
            
            var displayName: String {
                switch self {
                case .plane:
                    return "Plane"
                case .sphere:
                    return "Sphere"
                case .cube:
                    return "Cube"
                case .pyramid:
                    return "Pyramid"
                case .custom:
                    return "Custom"
                }
            }
        }
        
        var id: UUID
        var shape: Shape
        var material: Material
        
        var position: Vector3
        var rotation: Vector4
        var eulerAngles: Vector3
        var scale: Vector3
        
        init(id: UUID = UUID(), shape: SceneDocument.Object.Shape, material: SceneDocument.Material, position: SceneDocument.Vector3 = .zero, rotation: SceneDocument.Vector4 = .zero, eulerAngles: SceneDocument.Vector3 = .zero, scale: SceneDocument.Vector3 = .init(x: 1, y: 1, z: 1)) {
            self.id = id
            self.shape = shape
            self.material = material
            self.position = position
            self.rotation = rotation
            self.eulerAngles = eulerAngles
            self.scale = scale
        }
    }
    
    struct Camera: Identifiable, Codable, Hashable, Differentiable {
        var id: UUID = UUID()
        var position: Vector3 = .zero
        var rotation: Vector4 = .zero
        var eulerAngles: Vector3 = .zero
        var scale: Vector3 = .init(x: 1, y: 1, z: 1)
        
        var screenSpaceAmbientOcclusionOptions: ScreenSpaceAmbientOcclusionOptions = .init()
        var depthOfFieldOptions: DepthOfFieldOptions = .init()
        var bloomOptions: BloomOptions = .init()
        
        var filmGrainOptions: FilmGrainOptions = .init()
        var colorFringeOptions: ColorFringeOptions = .init()
        
        var useHDR: Bool = false
        var useAutoExposure: Bool = false
    }
    
    struct Light: Identifiable, Codable, Hashable, Differentiable {
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
    
    struct Vector2: Codable, Hashable, Differentiable {
        var x: Float
        var y: Float
        
        static var zero: Self = .init(x: 0, y: 0)
    }
    
    struct Vector3: Codable, Hashable, Differentiable {
        var x: Float
        var y: Float
        var z: Float
        
        static var zero: Self = .init(x: 0, y: 0, z: 0)
    }
    
    struct Vector4: Codable, Hashable, Differentiable {
        var x: Float
        var y: Float
        var z: Float
        var w: Float
        
        static var zero: Self = .init(x: 0, y: 0, z: 0, w: 0)
    }
    
    class Material: Codable, Hashable, Differentiable {
        static func == (lhs: SceneDocument.Material, rhs: SceneDocument.Material) -> Bool {
            return lhs.color == rhs.color && lhs.emission == rhs.emission && lhs.roughness == rhs.roughness
        }
        
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(color)
            hasher.combine(emission)
            hasher.combine(roughness)
        }
        
        var color: Color
        var emission: Float
        var roughness: Float
        
        init(color: SceneDocument.Color = .init(uiColor: .white), emission: Float = 0, roughness: Float = 1) {
            self.color = color
            self.emission = emission
            self.roughness = roughness
        }
        
        enum CodingKeys: String, CodingKey {
            case color
            case emission
            case roughness
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            color = (try? container.decode(Color.self, forKey: .color)) ?? .init(uiColor: .white)
            emission = (try? container.decode(Float.self, forKey: .emission)) ?? 0
            roughness = (try? container.decode(Float.self, forKey: .roughness)) ?? 0
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(color, forKey: .color)
            try container.encode(emission, forKey: .emission)
            try container.encode(roughness, forKey: .roughness)
        }
    }
    
    struct Color: Codable, Hashable, Differentiable {
        var red : CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
        
        var uiColor : UIColor {
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
        
        init(uiColor : UIColor) {
            uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
    }
    
    struct ScreenSpaceReflectionsOptions: Codable, Hashable, Differentiable {
        var isEnabled: Bool = false
        var sampleCount: Int = 64
        var maxDistance: Float = 128
    }
    
    struct ScreenSpaceAmbientOcclusionOptions: Codable, Hashable, Differentiable {
        var isEnabled: Bool = false
        var intensity: Float = 1
    }
    
    struct DepthOfFieldOptions: Codable, Hashable, Differentiable {
        var isEnabled: Bool = false
        var focusDistance: Float = 12
        var fStop: Float = 0.1
        var focalLength: Float = 16
    }
    
    struct FilmGrainOptions: Codable, Hashable, Differentiable {
        var isEnabled: Bool = false
        var scale: Float = 1.0
        var intensity: Float = 0.2
    }
    
    struct ColorFringeOptions: Codable, Hashable, Differentiable {
        var isEnabled: Bool = false
        var strength: Float = 0.5
        var intensity: Float = 0.5
    }
    
    struct BloomOptions: Codable, Hashable, Differentiable {
        var isEnabled: Bool = false
        var intensity: Float = 1.5
    }
    
    struct RaytracingOptions: Codable, Hashable, Differentiable {
        var isEnabled: Bool = false
    }
    
    enum Antialiasing: Codable, Hashable, Differentiable {
        case none
        case multisampling2X
        case multisampling4X
        case multisampling8X
        case multisampling16X
    }
    
    enum Preset: Codable {
        case cluster(shape: Object.Shape, positionMultiplier: Float = 10, objectCount: Int = 1000)
        case wall(shape: Object.Shape, positionMultiplier: Float = 2, objectCount: Int = 1000)
        
        var displayName: String {
            switch self {
            case .cluster:
                return "Cluster"
            case .wall:
                return "Wall"
            }
        }
        
        var shape: Object.Shape {
            switch self {
            case .cluster(let shape, _, _):
                return shape
            case .wall(let shape, _, _):
                return shape
            }
        }
        
        var positionMultiplier: Float {
            switch self {
            case .cluster(_, let positionMultiplier, _):
                return positionMultiplier
            case .wall(_, let positionMultiplier, _):
                return positionMultiplier
            }
        }
        
        var objectCount: Int {
            switch self {
            case .cluster(_, _, let objectCount):
                return objectCount
            case .wall(_, _, let objectCount):
                return objectCount
            }
        }
    }
    
    @Published var cameras: [Camera] = [.init()]
    
    @Published var objects: [Object] = []
    @Published var lights: [Light] = []
    @Published var backgroundColor: Color = .init(uiColor: .white)
    
    @Published var antialiasing: Antialiasing = .none
    
    @Published var raytracingOptions: RaytracingOptions = .init()
    @Published var screenSpaceReflectionsOptions: ScreenSpaceReflectionsOptions = .init()
    
    @Published var colorHue: ColorHue?
    @Published var preset: Preset?
    
    var previewImage: Data? = nil
    
    struct SceneDescriptorModel: Codable {
        var cameras: [Camera]
        
        var objects: [Object]
        var lights: [Light]
        var backgroundColor: Color
        
        var antialiasing: Antialiasing
        
        var raytracingOptions: RaytracingOptions
        var screenSpaceReflectionsOptions: ScreenSpaceReflectionsOptions
        
        var colorHue: ColorHue?
        var preset: Preset?
        
        init(_ document: SceneDocument) {
            self.cameras = document.cameras
            
            self.objects = document.objects
            self.lights = document.lights
            self.backgroundColor = document.backgroundColor
            
            self.antialiasing = document.antialiasing
            
            self.raytracingOptions = document.raytracingOptions
            self.screenSpaceReflectionsOptions = document.screenSpaceReflectionsOptions
            
            self.colorHue = document.colorHue
            self.preset = document.preset
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
        
        self.objects = sceneDescriptor.objects
        self.lights = sceneDescriptor.lights
        self.backgroundColor = sceneDescriptor.backgroundColor
        
        self.antialiasing = sceneDescriptor.antialiasing
        
        self.raytracingOptions = sceneDescriptor.raytracingOptions
        self.screenSpaceReflectionsOptions = sceneDescriptor.screenSpaceReflectionsOptions
        
        self.colorHue = sceneDescriptor.colorHue
        self.preset = sceneDescriptor.preset
        
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

struct ColorHue: Codable {
    var hue: String
    var luminosity: String
    
    var randomColorHue: RandomColor.Hue {
        switch hue {
        case "blue":
            return .blue
        case "orange":
            return .orange
        case "yellow":
            return .yellow
        case "green":
            return .green
        case "pink":
            return .pink
        case "purple":
            return .purple
        case "red":
            return .red
        case "monochrome":
            return .monochrome
        case "rainbow":
            return .random
        default:
            return .monochrome
        }
    }
    
    var randomColorLuminosity: RandomColor.Luminosity {
        switch luminosity {
        case "bright":
            return .bright
        case "light":
            return .light
        case "dark":
            return .dark
        case "random":
            return .random
        default:
            return .bright
        }
    }
    
    init(hue: RandomColor.Hue, luminosity: RandomColor.Luminosity = .bright) {
        switch hue {
        case .blue:
            self.hue = "blue"
        case .orange:
            self.hue = "orange"
        case .yellow:
            self.hue = "yellow"
        case .green:
            self.hue = "green"
        case .pink:
            self.hue = "pink"
        case .purple:
            self.hue = "purple"
        case .red:
            self.hue = "red"
        case .monochrome:
            self.hue = "monochrome"
        case .random:
            self.hue = "random"
        default:
            self.hue = "monochrome"
        }
        
        switch luminosity {
        case .bright:
            self.luminosity = "bright"
        case .light:
            self.luminosity = "light"
        case .dark:
            self.luminosity = "dark"
        case .random:
            self.luminosity = "random"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case hue
        case luminosity
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.hue = try container.decode(String.self, forKey: .hue)
        self.luminosity = try container.decode(String.self, forKey: .luminosity)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hue, forKey: .hue)
        try container.encode(luminosity, forKey: .luminosity)
    }
}