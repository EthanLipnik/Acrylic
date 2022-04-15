//
//  SceneService.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/29/22.
//

import Combine
import SceneKit
import RandomColor
import DifferenceKit

class SceneService: ObservableObject {
    var sceneDocument: SceneDocument
    var scene: SCNScene = .init()
    
    private var cancellables: Set<AnyCancellable> = []

    enum ShapePreset {
        case spheres
    }
    enum Preset {
        case random(ShapePreset)
    }
    
    init(_ document: SceneDocument) {
        self.sceneDocument = document
        
        if document.objects.isEmpty {
            setupDebugScene()
            saveDocument()
        }
        
        setupSceneView()
        
        sceneDocument.$objects
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.global(qos: .background))
            .sink { objects in
                let changeSet = StagedChangeset(source: self.sceneDocument.objects,
                                                target: objects)
                self.updateSceneDifference(changeSet: changeSet)
            }
            .store(in: &cancellables)
        
        sceneDocument.objectWillChange
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.global(qos: .background))
            .sink { [weak self] object in
                self?.saveDocument()
            }
            .store(in: &cancellables)
    }
    
    func saveDocument() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            if let fileUrl = self?.sceneDocument.fileURL {
                let previewImage = self?.render(resolution: CGSize(width: 512, height: 512))
                self?.sceneDocument.previewImage = previewImage?.jpegData(compressionQuality: 0.5)
                self?.sceneDocument.save(to: fileUrl, for: .forOverwriting)
                
                print("🟢 Saved scene document")
            }
        }
    }
    
    func setupDebugScene() {
        let hue = RandomColor.Hue.red
        let colors = randomColors(count: 1500, hue: hue, luminosity: .bright)
        func setupObjects() {
            var objects: [SceneDocument.Object] = []
            for _ in 0..<1500 {
                let randomScale = Float.random(in: 0.1..<1)
                let sphere = SceneDocument.Object(shape: .sphere(),
                                                  material: .init(color: .init(uiColor: colors.randomElement() ?? .magenta), roughness: 0.6),
                                                  position: .init(x: Float.random(in: -10..<10), y: Float.random(in: -10..<10), z: Float.random(in: -10..<10)),
                                                  scale: .init(x: randomScale, y: randomScale, z: randomScale))
                objects.append(sphere)
            }
            
            sceneDocument.objects = objects
        }
        
        func setupSettings() {
            sceneDocument.antialiasing = .multisampling2X
            sceneDocument.screenSpaceReflectionsOptions = .init(isEnabled: true, sampleCount: 64, maxDistance: 128)
        }
        
        func setupLights() {
            let directionalLight = SceneDocument.Light(lightType: .directional,
                                                       castsShadow: true,
                                                       eulerAngles: SceneDocument.Vector3(x: 0, y: 45, z: 45))
            
            let ambientLight = SceneDocument.Light(lightType: .ambient,
                                                   color: SceneDocument.Color.init(uiColor: UIColor(hue: 0, saturation: 0, brightness: 0.7, alpha: 1)),
                                                   castsShadow: false)
            
            sceneDocument.lights = [directionalLight, ambientLight]
        }
        
        func setupCameras() {
            let camera = SceneDocument.Camera(position: SceneDocument.Vector3(x: 0, y: 0, z: 12),
                                              screenSpaceAmbientOcclusionOptions: .init(isEnabled: true, intensity: 1.8),
                                              depthOfFieldOptions: .init(isEnabled: true, focusDistance: 12, fStop: 0.1, focalLength: 16),
                                              bloomOptions: .init(isEnabled: true, intensity: 0.2),
                                              filmGrainOptions: .init(isEnabled: true, scale: 1, intensity: 0.2),
                                              colorFringeOptions: .init(isEnabled: true, strength: 0.5, intensity: 0.5),
                                              useHDR: true,
                                              useAutoExposure: true)
            sceneDocument.cameras = [camera]
        }
        
        setupObjects()
        setupSettings()
        setupLights()
        setupCameras()
    }
    
    func updateSceneDifference<Model: Differentiable>(changeSet: StagedChangeset<[Model]>) {
        print("Scene updated", changeSet.map({ $0.changeCount }))
        changeSet.forEach { change in
            let inserted = change.elementInserted.map({ change.data[$0.element] })
            inserted.forEach { insert in
                if let object = insert as? SceneDocument.Object {
                    addNode(object)
                }
            }
            
            let deleted = change.elementDeleted.map({ change.data[$0.element] })
            deleted.forEach { delete in
                if let object = delete as? SceneDocument.Object, let node = scene.rootNode.childNode(withName: object.id.uuidString, recursively: false) {
                    node.removeFromParentNode()
                }
            }
            
            let updated = change.elementUpdated.map({ change.data[$0.element] })
            updated.forEach { update in
                if let object = update as? SceneDocument.Object, let node = scene.rootNode.childNode(withName: object.id.uuidString, recursively: false) {
                    
                    let newNode = node
                    switch object.shape {
                    case .sphere(let segmentCount):
                        let sphere = SCNSphere(radius: CGFloat(object.scale.x + object.scale.y + object.scale.z) / 3)
                        sphere.segmentCount = segmentCount
                        newNode.geometry = sphere
                    default:
                        break
                    }
                    newNode.geometry?.firstMaterial?.lightingModel = .physicallyBased
                    newNode.geometry?.firstMaterial?.diffuse.contents = object.material.color.uiColor
                    newNode.geometry?.firstMaterial?.roughness.contents = object.material.roughness
                    
                    newNode.castsShadow = true
                    
                    newNode.position = SCNVector3(object.position.x, object.position.y, object.position.z)
                    
                    scene.rootNode.replaceChildNode(node, with: newNode)
                }
            }
        }
    }
    
    func setupSceneView() {
        
        scene.wantsScreenSpaceReflection = sceneDocument.screenSpaceReflectionsOptions.isEnabled
        scene.screenSpaceReflectionSampleCount = sceneDocument.screenSpaceReflectionsOptions.sampleCount
        scene.screenSpaceReflectionMaximumDistance = CGFloat(sceneDocument.screenSpaceReflectionsOptions.maxDistance)
        
        scene.background.contents = sceneDocument.backgroundColor
        
        // TODO: - Make this diffable
        scene.rootNode.childNodes.forEach({ $0.removeFromParentNode() })
        
        let camera = sceneDocument.cameras.first!
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.wantsExposureAdaptation = camera.useAutoExposure
        cameraNode.camera?.wantsHDR = camera.useHDR
        cameraNode.camera?.wantsDepthOfField = camera.depthOfFieldOptions.isEnabled
        cameraNode.camera?.screenSpaceAmbientOcclusionIntensity = camera.screenSpaceAmbientOcclusionOptions.isEnabled ? CGFloat(camera.screenSpaceAmbientOcclusionOptions.intensity) : 0
        cameraNode.camera?.bloomIntensity = camera.bloomOptions.isEnabled ? CGFloat(camera.bloomOptions.intensity) : 0
        
        cameraNode.camera?.grainIntensity = camera.filmGrainOptions.isEnabled ? CGFloat(camera.filmGrainOptions.intensity) : 0
        cameraNode.camera?.grainScale = CGFloat(camera.filmGrainOptions.scale)
        cameraNode.camera?.grainIsColored = true
        
        cameraNode.camera?.focusDistance = CGFloat(camera.depthOfFieldOptions.focusDistance)
        cameraNode.camera?.fStop = CGFloat(camera.depthOfFieldOptions.fStop)
        cameraNode.camera?.focalLength = CGFloat(camera.depthOfFieldOptions.focalLength)
        cameraNode.camera?.fieldOfView = 50
        cameraNode.camera?.zNear = 0
        
        cameraNode.camera?.colorFringeStrength = camera.colorFringeOptions.isEnabled ? CGFloat(camera.colorFringeOptions.strength) : 0
        cameraNode.camera?.colorFringeIntensity = camera.colorFringeOptions.isEnabled ? CGFloat(camera.colorFringeOptions.intensity) : 0
        cameraNode.camera?.averageGray = 0.2
        cameraNode.position = SCNVector3(camera.position.x, camera.position.y, camera.position.z)
        scene.rootNode.addChildNode(cameraNode)
        
        sceneDocument.lights.forEach { light in
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
        
        sceneDocument.objects.forEach { object in
            addNode(object)
        }
    }
    
    func addNode(_ object: SceneDocument.Object) {
        let node: SCNNode
        
        switch object.shape {
        case .sphere(let segmentCount):
            let sphere = SCNSphere(radius: CGFloat(object.scale.x + object.scale.y + object.scale.z) / 3)
            sphere.segmentCount = segmentCount
            node = SCNNode(geometry:  sphere)
        default:
            // TODO: - Add more shape options
            node = SCNNode()
        }
        node.geometry?.firstMaterial?.lightingModel = .physicallyBased
        node.geometry?.firstMaterial?.diffuse.contents = object.material.color.uiColor
        node.geometry?.firstMaterial?.roughness.contents = object.material.roughness
        
        node.castsShadow = true
        
        node.position = SCNVector3(object.position.x, object.position.y, object.position.z)
        
        node.name = object.id.uuidString
        
        scene.rootNode.addChildNode(node)
    }
    
    func render(resolution: CGSize = CGSize(width: 1024, height: 1024)) -> UIImage {
        let renderer = SCNRenderer(device: MTLCreateSystemDefaultDevice())
        renderer.scene = scene
        
        let renderTime = TimeInterval(1)
        renderer.update(atTime: .zero)
        renderer.sceneTime = renderTime
        
        return renderer.snapshot(atTime: renderTime, with: resolution, antialiasingMode: .multisampling4X)
    }
}
