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
    
    public final func create(_ colors: [UIColor], width: Int = 3, height: Int = 3) {
        let elements = MeshNode.generateElements(width: width, height: height, colors: [
            .init(point: (0, 0), location: (0, 0), color: UIColor(red: 0.149, green: 0.275, blue: 0.325, alpha: 1.000)),
            .init(point: (0, 1), location: (0, 1), color: UIColor(red: 0.157, green: 0.447, blue: 0.443, alpha: 1.000)),
            .init(point: (0, 2), location: (0, 2), color: UIColor(red: 0.165, green: 0.616, blue: 0.561, alpha: 1.000)),
            
            .init(point: (1, 0), location: (1, 0), color: UIColor(red: 0.541, green: 0.694, blue: 0.490, alpha: 1.000)),
            .init(point: (1, 1), location: (Float.random(in: 0.3...1.8), Float.random(in: 0.3...1.5)), color: UIColor(red: 0.541, green: 0.694, blue: 0.490, alpha: 1.000)),
            .init(point: (1, 2), location: (1, 2), color: UIColor(red: 0.914, green: 0.769, blue: 0.416, alpha: 1.000)),
            
            .init(point: (2, 0), location: (2, 0), color: UIColor(red: 0.957, green: 0.635, blue: 0.380, alpha: 1.000)),
            .init(point: (2, 1), location: (2, 1), color: UIColor(red: 0.933, green: 0.537, blue: 0.349, alpha: 1.000)),
            .init(point: (2, 2), location: (2, 2), color: UIColor(red: 0.906, green: 0.435, blue: 0.318, alpha: 1.000)),
        ])
        
        if let node = scene.rootNode.childNode(withName: "meshNode", recursively: false) {
            node.geometry = SCNNode.get(points: elements.points, colors: elements.colors)
        } else {
            let node = MeshNode.node(elements: elements)
            node.name = "meshNode"
            
            scene.rootNode.addChildNode(node)
        }
    }
}
