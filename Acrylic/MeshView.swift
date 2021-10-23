//
//  MeshView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import UIKit
import SceneKit

class MeshView: UIView {

    // MARK: - Views
    lazy var scene: SCNScene = {
        let scene = SCNScene()
        
        return scene
    }()
    lazy var sceneView: SCNView = {
        let view = SCNView()
        
        view.scene = scene
        view.allowsCameraControl = false
        view.debugOptions = debugOptions
        view.isUserInteractionEnabled = false
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // MARK: - Variables
    lazy var debugOptions: SCNDebugOptions = []
    
    // MARK: - Setup
    init() {
        super.init(frame: .zero)
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    private final func setup() {
        addSubview(sceneView)
        
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    public final func create(_ colors: [MeshNode.Color], width: Int = 3, height: Int = 3) {
        let elements = MeshNode.generateElements(width:width,
                                                 height: height,
                                                 colors: colors)
        
        if let node = scene.rootNode.childNode(withName: "meshNode",
                                               recursively: false) {
            node.geometry = SCNNode.get(points: elements.points,
                                        colors: elements.colors)
        } else {
            let node = MeshNode.node(elements: elements)
            node.name = "meshNode"
            
            scene.rootNode.addChildNode(node)
        }
    }
}
