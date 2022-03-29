//
//  SceneService.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/29/22.
//

import Combine
import SceneKit

class SceneService: ObservableObject {
    var sceneDocument: SceneDocument? = nil
    var scene: SCNScene = .init()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(_ document: SceneDocument? = nil) {
        self.sceneDocument = document
        
        // TODO: Document saving
        if let document = document {
            
            objectWillChange
                .debounce(for: .seconds(1), scheduler: DispatchQueue.global(qos: .background))
                .sink { [weak self] object in
                    guard let self = self else { return }
                    
//                    self.saveDocument()
                }
                .store(in: &cancellables)
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
                
                print("🟢 Saved mesh document")
            }
        }
    }
    
    func render(resolution: CGSize = CGSize(width: 1024, height: 1024)) -> UIImage {
        let renderer = SCNRenderer(device: MTLCreateSystemDefaultDevice())
        renderer.scene = scene
        return renderer.snapshot(atTime: .zero, with: resolution, antialiasingMode: .multisampling16X)
    }
}
