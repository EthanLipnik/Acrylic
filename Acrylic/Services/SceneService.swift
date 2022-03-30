//
//  SceneService.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/29/22.
//

import Combine
import SceneKit
import RandomColor

class SceneService: ObservableObject {
    var sceneDocument: SceneDocument? = nil
    var scene: SCNScene = .init()
    
    @Published var objects: Set<SceneDocument.Object> = []
    @Published var lights: Set<SceneDocument.Light> = []
    @Published var camera: SceneDocument.Camera = .init()
    
    @Published var useHDR: Bool = false
    @Published var useAutoExposure: Bool = false
    @Published var antialiasing: SceneDocument.Antialiasing = .none
    @Published var screenSpaceReflectionsOptions: SceneDocument.ScreenSpaceReflectionsOptions = .init()
    @Published var screenSpaceAmbientOcclusionOptions: SceneDocument.ScreenSpaceAmbientOcclusionOptions = .init()
    @Published var bloomOptions: SceneDocument.BloomOptions = .init()
    @Published var depthOfFieldOptions: SceneDocument.DepthOfFieldOptions = .init()
    @Published var colorFringeOptions: SceneDocument.ColorFringeOptions = .init()
    
    @Published var backgroundColor: UIColor = .white
    
    private var cancellables: Set<AnyCancellable> = []

    enum ShapePreset {
        case spheres
    }
    enum Preset {
        case random(ShapePreset)
    }
    
    init(_ document: SceneDocument? = nil) {
        self.sceneDocument = document
        
        // TODO: Document saving
        if let document = document {
            self.objects = document.objects
            self.lights = document.lights
            self.camera = document.camera
            self.useHDR = document.useHDR
            self.useAutoExposure = document.useAutoExposure
            self.antialiasing = document.antialiasing
            self.screenSpaceReflectionsOptions = document.screenSpaceReflectionsOptions
            self.screenSpaceAmbientOcclusionOptions = document.screenSpaceAmbientOcclusionOptions
            self.bloomOptions = document.bloomOptions
            self.depthOfFieldOptions = document.depthOfFieldOptions
            self.colorFringeOptions = document.colorFringeOptions
            self.backgroundColor = document.backgroundColor.uiColor
            
            objectWillChange
                .debounce(for: .seconds(1), scheduler: DispatchQueue.global(qos: .background))
                .sink { [weak self] object in
                    guard let self = self else { return }
                    self.updateSceneView()
                    
                    self.sceneDocument?.objects = self.objects
                    self.sceneDocument?.lights = self.lights
                    self.sceneDocument?.camera = self.camera
                    self.sceneDocument?.useHDR = self.useHDR
                    self.sceneDocument?.useAutoExposure = self.useAutoExposure
                    self.sceneDocument?.antialiasing = self.antialiasing
                    self.sceneDocument?.screenSpaceReflectionsOptions = self.screenSpaceReflectionsOptions
                    self.sceneDocument?.screenSpaceAmbientOcclusionOptions = self.screenSpaceAmbientOcclusionOptions
                    self.sceneDocument?.bloomOptions = self.bloomOptions
                    self.sceneDocument?.depthOfFieldOptions = self.depthOfFieldOptions
                    self.sceneDocument?.colorFringeOptions = self.colorFringeOptions
                    self.sceneDocument?.backgroundColor = .init(uiColor: self.backgroundColor)
                    
                    self.saveDocument()
                }
                .store(in: &cancellables)
            
            if document.objects.isEmpty {
                setupDebugScene()
            }
        }
    }
    
    func saveDocument() {
        if let fileUrl = sceneDocument?.fileURL {
            DispatchQueue.global(qos: .background).async { [weak self] in
                do {
                    let previewImage = self?.render(resolution: CGSize(width: 512, height: 512))
                    self?.sceneDocument?.previewImage = try previewImage?.heicData(compressionQuality: 0.5)
                } catch {
                    print("Failed to render and save preview")
                }
                self?.sceneDocument?.save(to: fileUrl, for: .forOverwriting)
                
                print("🟢 Saved scene document")
            }
        }
    }
    
    func setupDebugScene() {
        let hue = RandomColor.Hue.red
        let colors = randomColors(count: 1500, hue: hue, luminosity: .bright)
        func setupObjects() {
            var objects: Set<SceneDocument.Object> = []
            for _ in 0..<1500 {
                let randomScale = Float.random(in: 0.1..<1)
                let sphere = SceneDocument.Object(shape: .sphere, material: .init(color: .init(uiColor: colors.randomElement() ?? .magenta), roughness: 0.5),
                                                  position: .init(x: Float.random(in: -10..<10), y: Float.random(in: -10..<10), z: Float.random(in: -10..<10)),
                                                  scale: .init(x: randomScale, y: randomScale, z: randomScale))
                objects.insert(sphere)
            }
            
            self.objects = objects
        }
        
        func setupSettings() {
            useHDR = true
            useAutoExposure = true
            antialiasing = .multisampling2X
            screenSpaceReflectionsOptions = .init(isEnabled: true, sampleCount: 64, maxDistance: 128)
            screenSpaceAmbientOcclusionOptions = .init(isEnabled: true, intensity: 1.8)
            bloomOptions = .init(isEnabled: true, intensity: 1.5)
            depthOfFieldOptions = .init(isEnabled: true, focusDistance: 6, fStop: 0.1, focalLength: 16)
            colorFringeOptions = .init(isEnabled: true, strength: 0.8, intensity: 0.8)
            backgroundColor = randomColor(hue: hue, luminosity: .light)
        }
        
        func setupLights() {
            let directionalLight = SceneDocument.Light(lightType: .directional,
                                                       castsShadow: true,
                                                       eulerAngles: SceneDocument.Vector3(x: 0, y: 45, z: 45))
            
            let ambientLight = SceneDocument.Light(lightType: .ambient,
                                                   color: SceneDocument.Color.init(uiColor: UIColor(hue: 0, saturation: 0, brightness: 0.7, alpha: 1)),
                                                   castsShadow: false)
            
            self.lights = [directionalLight, ambientLight]
        }
        
        // TODO: - Move some settings to camera than scene
        func setupCameras() {
            let camera = SceneDocument.Camera(position: SceneDocument.Vector3(x: 0, y: 0, z: 12))
            self.camera = camera
        }
        
        setupObjects()
        setupSettings()
        setupLights()
        setupCameras()
    }
    
    func updateSceneView() {
        scene.background.contents = backgroundColor
        
        // TODO: - Make this diffable
        scene.rootNode.childNodes.forEach({ $0.removeFromParentNode() })
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.wantsHDR = useHDR
        cameraNode.camera?.wantsDepthOfField = depthOfFieldOptions.isEnabled
        cameraNode.camera?.screenSpaceAmbientOcclusionIntensity = screenSpaceAmbientOcclusionOptions.isEnabled ? CGFloat(screenSpaceAmbientOcclusionOptions.intensity) : 0
        cameraNode.camera?.motionBlurIntensity = 0.5
        cameraNode.camera?.bloomIntensity = bloomOptions.isEnabled ? CGFloat(bloomOptions.intensity) : 0
        
        cameraNode.camera?.focusDistance = CGFloat(depthOfFieldOptions.focusDistance)
        cameraNode.camera?.fStop = CGFloat(depthOfFieldOptions.fStop)
        cameraNode.camera?.focalLength = CGFloat(depthOfFieldOptions.focalLength)
        cameraNode.camera?.fieldOfView = 50
        cameraNode.camera?.zNear = 0
        
        cameraNode.camera?.colorFringeStrength = colorFringeOptions.isEnabled ? CGFloat(colorFringeOptions.strength) : 0
        cameraNode.camera?.colorFringeIntensity = colorFringeOptions.isEnabled ? CGFloat(colorFringeOptions.intensity) : 0
        cameraNode.camera?.averageGray = 0.2
        cameraNode.position = SCNVector3(camera.position.x, camera.position.y, camera.position.z)
        scene.rootNode.addChildNode(cameraNode)
        
        lights.forEach { light in
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            
            lightNode.light?.color = light.color.uiColor
            lightNode.light?.castsShadow = light.castsShadow
            lightNode.light?.orthographicScale = 10
            
            lightNode.eulerAngles = SCNVector3(light.eulerAngles.x, light.eulerAngles.y, light.eulerAngles.z)
            
            if light.castsShadow {
                lightNode.light?.shadowSampleCount = 64
            }
            
            switch light.lightType {
            case .directional:
                lightNode.light?.type = .directional
            case .ambient:
                lightNode.light?.type = .ambient
            default:
                // TODO: - Add more light options
                break
            }
            
            scene.rootNode.addChildNode(lightNode)
        }
        
        objects.forEach { object in
            let node: SCNNode
            
            switch object.shape {
            case .sphere:
                let sphere = SCNSphere(radius: CGFloat(object.scale.x + object.scale.y + object.scale.z) / 3)
                sphere.segmentCount = 64
                node = SCNNode(geometry:  sphere)
            default:
                // TODO: - Add more shape options
                node = SCNNode()
            }
            node.geometry?.firstMaterial?.lightingModel = .physicallyBased
            node.geometry?.firstMaterial?.diffuse.contents = object.material.color.uiColor
            node.geometry?.firstMaterial?.roughness.contents = 0.5
            
            node.castsShadow = true
            
            node.position = SCNVector3(object.position.x, object.position.y, object.position.z)
            
            scene.rootNode.addChildNode(node)
        }
    }
    
    func render(resolution: CGSize = CGSize(width: 1024, height: 1024)) -> UIImage {
        let renderer = SCNRenderer(device: MTLCreateSystemDefaultDevice())
        renderer.scene = scene
        return renderer.snapshot(atTime: .zero, with: resolution, antialiasingMode: .multisampling4X)
    }
}
