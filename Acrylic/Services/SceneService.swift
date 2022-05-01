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

class SceneService: NSObject, ObservableObject {
    var sceneDocument: SceneDocument
    var scene: SCNScene = .init()
    var sceneView: SCNView? = nil {
        didSet {
            sceneView?.defaultCameraController.delegate = self
        }
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(_ document: SceneDocument) {
        self.sceneDocument = document
        super.init()
        
        if document.objects.isEmpty {
            self.sceneDocument.setPreset(.cluster(shape: .cube(chamferEdges: 0.1, segmentCount: 4), positionMultiplier: 3, objectCount: 500))
            saveDocument()
        }
        
        setupSceneView()
        
        sceneDocument.$objects
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] objects in
//                let changeSet = StagedChangeset(source: self.sceneDocument.objects,
//                                                target: objects)
//                self.updateSceneDifference(changeSet: changeSet)
                self?.setupSceneView()
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
                let previewImage = self?.render(resolution: CGSize(width: 512, height: 512), useAntialiasing: false)
                self?.sceneDocument.previewImage = previewImage?.jpegData(compressionQuality: 0.5)
                self?.sceneDocument.save(to: fileUrl, for: .forOverwriting)
                
                print("🟢 Saved scene document")
            }
        }
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
        print("SceneService", "Setting up scene view")
        
        scene.wantsScreenSpaceReflection = sceneDocument.screenSpaceReflectionsOptions.isEnabled
        scene.screenSpaceReflectionSampleCount = sceneDocument.screenSpaceReflectionsOptions.sampleCount
        scene.screenSpaceReflectionMaximumDistance = CGFloat(sceneDocument.screenSpaceReflectionsOptions.maxDistance)
        
        scene.background.contents = sceneDocument.backgroundColor.uiColor
        
        // TODO: - Make this diffable
        scene.rootNode.childNodes.forEach({ $0.removeFromParentNode() })
        
        if let camera = sceneDocument.cameras.first {
            let cameraNode = SCNNode()
            cameraNode.name = "Camera"
            cameraNode.camera = SCNCamera()
            cameraNode.camera?.wantsExposureAdaptation = camera.useAutoExposure
            cameraNode.camera?.wantsHDR = camera.useHDR
            cameraNode.camera?.wantsDepthOfField = camera.depthOfFieldOptions.isEnabled
            cameraNode.camera?.screenSpaceAmbientOcclusionIntensity = camera.screenSpaceAmbientOcclusionOptions.isEnabled ? CGFloat(camera.screenSpaceAmbientOcclusionOptions.intensity) : 0
            cameraNode.camera?.bloomIntensity = camera.bloomOptions.isEnabled ? CGFloat(camera.bloomOptions.intensity) : 0
            cameraNode.camera?.minimumExposure = 0.5
            
            cameraNode.camera?.grainIntensity = camera.filmGrainOptions.isEnabled ? CGFloat(camera.filmGrainOptions.intensity) : 0
            cameraNode.camera?.grainScale = CGFloat(camera.filmGrainOptions.scale)
            cameraNode.camera?.grainIsColored = false
            
            cameraNode.camera?.focusDistance = CGFloat(camera.depthOfFieldOptions.focusDistance)
            cameraNode.camera?.fStop = CGFloat(camera.depthOfFieldOptions.fStop)
            cameraNode.camera?.focalLength = CGFloat(camera.depthOfFieldOptions.focalLength)
            cameraNode.camera?.fieldOfView = 50
            cameraNode.camera?.zNear = 0
            
            cameraNode.camera?.vignettingIntensity = 0.2
            cameraNode.camera?.vignettingPower = 0.3
            
            cameraNode.camera?.colorFringeStrength = camera.colorFringeOptions.isEnabled ? CGFloat(camera.colorFringeOptions.strength) : 0
            cameraNode.camera?.colorFringeIntensity = camera.colorFringeOptions.isEnabled ? CGFloat(camera.colorFringeOptions.intensity) : 0
            cameraNode.position = SCNVector3(camera.position.x, camera.position.y, camera.position.z)
            cameraNode.eulerAngles = SCNVector3(x: camera.eulerAngles.x, y: camera.eulerAngles.y, z: camera.eulerAngles.z)
            cameraNode.rotation = SCNVector4(x: camera.rotation.x, y: camera.rotation.y, z: camera.rotation.z, w: camera.rotation.w)
            scene.rootNode.addChildNode(cameraNode)
        }
        
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
        
        sceneView?.defaultCameraController.delegate = self
    }
    
    func addNode(_ object: SceneDocument.Object) {
        let node: SCNNode
        
        switch object.shape {
        case .sphere(let segmentCount):
            let sphere = SCNSphere(radius: CGFloat(object.scale.x + object.scale.y + object.scale.z) / 3)
            sphere.segmentCount = segmentCount
            node = SCNNode(geometry: sphere)
        case .cube(let chamferEdges, let segmentCount):
            let box = SCNBox(width: CGFloat(object.scale.x), height: CGFloat(object.scale.y), length: CGFloat(object.scale.z), chamferRadius: CGFloat(chamferEdges))
            box.chamferSegmentCount = segmentCount
            node = SCNNode(geometry: box)
        case .pyramid:
            let pyamid = SCNPyramid(width: CGFloat(object.scale.x), height: CGFloat(object.scale.y), length: CGFloat(object.scale.z))
            node = SCNNode(geometry: pyamid)
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
    
    func updateObjectCount(_ objectCount: Int) {
        let difference = sceneDocument.objects.count - objectCount
        let differenceAbs = abs(difference)
        
        let colors = randomColors(count: differenceAbs, hue: sceneDocument.colorHue!.randomColorHue, luminosity: sceneDocument.colorHue!.randomColorLuminosity)
        
        var objects = sceneDocument.objects
        let roughness = objects.first?.material.roughness ?? 0.6
        for _ in 0..<differenceAbs {
            if difference < 0 {
                let randomScale = Float.random(in: 0.1..<1)
                switch sceneDocument.preset {
                case .cluster(let shape, let positionMultiplier, _):
                    let object = SceneDocument.Object(shape: shape,
                                                      material: .init(color: .init(uiColor: colors.randomElement() ?? .magenta), roughness: roughness),
                                                      position: .init(x: Float.random(in: -positionMultiplier..<positionMultiplier), y: Float.random(in: -positionMultiplier..<positionMultiplier), z: Float.random(in: -positionMultiplier..<positionMultiplier)),
                                                      scale: .init(x: randomScale, y: randomScale, z: randomScale))
                    objects.append(object)
                default:
                    break
                }
            } else {
                objects.removeLast()
            }
        }
        
        sceneDocument.objects = objects
    }
    
    func render(resolution: CGSize = CGSize(width: 1024, height: 1024), useAntialiasing: Bool = true) -> UIImage {
        let renderer = SCNRenderer(device: MTLCreateSystemDefaultDevice())
        renderer.scene = scene
        
        if let pointOfView = sceneView?.pointOfView {
            renderer.pointOfView = pointOfView
        } else {
            renderer.pointOfView = scene.rootNode.childNode(withName: "Camera", recursively: false)
        }
        
        if let camera = sceneDocument.cameras.first {
            let aspectRatio = resolution.width / 1024
            let ambientOcclusion = CGFloat(camera.screenSpaceAmbientOcclusionOptions.intensity)
            renderer.pointOfView?.camera?.screenSpaceAmbientOcclusionIntensity = (ambientOcclusion / aspectRatio) + (aspectRatio != 1 ? 0.5 : 0)
            
            let filmGrainScale = CGFloat(camera.filmGrainOptions.scale)
            renderer.pointOfView?.camera?.grainScale = filmGrainScale * aspectRatio
        }
        
        let renderTime = TimeInterval(3)
        renderer.update(atTime: renderTime)
        renderer.sceneTime = renderTime
        
        var supportsAntialiasing: Bool = true
#if targetEnvironment(simulator)
        supportsAntialiasing = false
#endif
        
        return renderer.snapshot(atTime: renderTime, with: resolution, antialiasingMode: (useAntialiasing && supportsAntialiasing) ? .multisampling4X : .none)
    }
    
    func setPreset(_ preset: String?, shape: String? = nil) {
        var currentShape = sceneDocument.preset?.shape ?? .sphere()
        var currentPositionMultiplier = sceneDocument.preset?.positionMultiplier ?? 1
        let currentObjectCount = sceneDocument.objects.count
        
        guard self.sceneDocument.preset?.displayName.lowercased() != preset || currentShape.displayName.lowercased() != (shape ?? currentShape.displayName) else { return }
        
        if let shape = shape {
            switch shape {
            case "sphere":
                currentShape = .sphere()
                currentPositionMultiplier = 10
            case "cube":
                currentShape = .cube(chamferEdges: 0.1, segmentCount: 4)
                currentPositionMultiplier = 3
            case "pyramid":
                currentShape = .pyramid
                currentPositionMultiplier = 6
            default:
                break
            }
        }
        
        switch preset {
        case "cluster":
            sceneDocument.setPreset(.cluster(shape: currentShape,
                                             positionMultiplier: currentPositionMultiplier,
                                             objectCount: currentObjectCount),
                                    hue: sceneDocument.colorHue?.randomColorHue)
            setupSceneView()
        case "wall":
            sceneDocument.setPreset(.wall(shape: currentShape,
                                          positionMultiplier: currentPositionMultiplier,
                                          objectCount: currentObjectCount),
                                    hue: sceneDocument.colorHue?.randomColorHue)
            setupSceneView()
            
//            if x + 1 == currentObjectCount / 2 && y + 1 == currentObjectCount / 2 {
//                sceneView?.defaultCameraController.translateInCameraSpaceBy(x: node.position.x, y: node.position.y, z: 0)
//            }
        default:
            return
        }
    }
}

extension SceneService: SCNCameraControllerDelegate {
    func cameraInertiaDidEnd(for cameraController: SCNCameraController) {
        guard let pointOfView = cameraController.pointOfView else { return }
        sceneDocument.cameras[0].position = .init(x: pointOfView.position.x, y: pointOfView.position.y, z: pointOfView.position.z)
        sceneDocument.cameras[0].eulerAngles = .init(x: pointOfView.eulerAngles.x, y: pointOfView.eulerAngles.y, z: pointOfView.eulerAngles.z)
        sceneDocument.cameras[0].rotation = .init(x: pointOfView.rotation.x, y: pointOfView.rotation.y, z: pointOfView.rotation.z, w: pointOfView.rotation.w)
        
        saveDocument()
    }
    
    func cameraInertiaWillStart(for cameraController: SCNCameraController) {
    }
}
