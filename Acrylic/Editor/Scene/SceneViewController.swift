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
    
    lazy var sceneContainerView: UIView = {
        let view = UIView()
        
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowRadius = 30
        view.layer.shadowOpacity = 0.4
        
        view.layer.cornerRadius = 30
        view.layer.cornerCurve = .continuous
        
        view.addSubview(sceneView)
        
        return view
    }()
    lazy var sceneView: SCNView = {
        let view = SCNView()
        
        view.scene = sceneService.scene
        view.allowsCameraControl = true
        view.showsStatistics = true
        
        view.layer.cornerRadius = 30
        view.layer.cornerCurve = .continuous
        
        view.layer.masksToBounds = true
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.contentScaleFactor = 0.9
        
        return view
    }()
    
    let sceneService: SceneService
    
    init(_ sceneService: SceneService) {
        self.sceneService = sceneService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(UIDevice.current.userInterfaceIdiom == .mac, animated: false)
        
        view.backgroundColor = UIColor.systemBackground
        
        view.addSubview(sceneContainerView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if traitCollection.horizontalSizeClass == .compact {
            let meshSize = min(view.bounds.height, view.bounds.width) - 48
            sceneContainerView.frame = CGRect(x: 24, y: 24, width: meshSize, height: meshSize)
            sceneContainerView.center = view.center
        } else {
            let meshSize = min(view.bounds.height, view.bounds.width) - (40 + (view.safeAreaInsets.vertical * 2))
            sceneContainerView.frame = CGRect(x: 20, y: 20, width: meshSize, height: meshSize)
            sceneContainerView.center = CGPoint(x: view.center.x, y: view.center.y + (view.safeAreaInsets.top / 2) - (view.safeAreaInsets.bottom / 2))
        }
    }
}
