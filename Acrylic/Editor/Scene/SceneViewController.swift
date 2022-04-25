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
        
        view.backgroundColor = UIColor.secondarySystemBackground
        
        view.addSubview(sceneView)
        view.addSubview(previewImageView)
        
        view.hero.id = sceneService.sceneDocument.fileURL.path
        view.hero.modifiers = [.spring(stiffness: 250, damping: 20)]
        
        return view
    }()
    lazy var sceneView: SCNView = {
        let view = SCNView()
        
        view.scene = sceneService.scene
        view.allowsCameraControl = true
        view.showsStatistics = false
        
        view.layer.cornerRadius = 30
        view.layer.cornerCurve = .continuous
        
        view.layer.masksToBounds = true
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return view
    }()
    
    lazy var previewImageView: UIImageView = {
        var image: UIImage?
        if let data = sceneService.sceneDocument.previewImage {
            image = UIImage(data: data)
        }
        
        let imageView = UIImageView(image: image)
        imageView.layer.cornerRadius = 30
        imageView.layer.cornerCurve = .continuous
        imageView.layer.masksToBounds = true
        
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.frame = sceneView.bounds
        
        return imageView
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
        
        sceneService.sceneView = sceneView
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        sceneService.sceneView = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.previewImageView.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        previewImageView.isHidden = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if traitCollection.horizontalSizeClass == .compact {
            let meshSize = min(view.bounds.height, view.bounds.width) - 48
            sceneContainerView.frame = CGRect(x: 24, y: 24 + view.safeAreaInsets.top, width: meshSize, height: meshSize)
            sceneContainerView.center.x = view.center.x
        } else {
            let meshSize = min(view.bounds.height, view.bounds.width) - (40 + (view.safeAreaInsets.vertical * 2))
            sceneContainerView.frame = CGRect(x: 20, y: 20, width: meshSize, height: meshSize)
            sceneContainerView.center = CGPoint(x: view.center.x, y: view.center.y + (view.safeAreaInsets.top / 2) - (view.safeAreaInsets.bottom / 2))
        }
    }
}
