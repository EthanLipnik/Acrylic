//
//  SceneViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/29/22.
//

import UIKit
import SceneKit
import Combine

class SceneViewController: UIViewController {

    lazy var sceneView: SCNView = {
        let view = SCNView()
        
        view.layer.cornerRadius = 30
        view.layer.cornerCurve = .continuous
        
        view.subviews.forEach({ $0.layer.cornerRadius = 30; $0.layer.cornerCurve = .continuous; $0.layer.masksToBounds = true })
        
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowRadius = 30
        view.layer.shadowOpacity = 0.4
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    var sceneService: SceneService = .init()
    
    init(_ sceneService: SceneService) {
        self.sceneService = sceneService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(UIDevice.current.userInterfaceIdiom == .mac, animated: false)
        
        view.backgroundColor = UIColor.systemBackground
        
        view.addSubview(sceneView)
        
        NSLayoutConstraint.activate([
            sceneView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            sceneView.widthAnchor.constraint(equalTo: sceneView.heightAnchor),
            sceneView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }
}
