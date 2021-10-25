//
//  EditorViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import UIKit
import MeshKit
import Combine

class EditorViewController: UIViewController {
    
    lazy var meshView: MeshView = {
        let view = MeshView()
        
        view.layer.cornerRadius = 30
        view.layer.cornerCurve = .continuous
        
        view.subviews.forEach({ $0.layer.cornerRadius = 30; $0.layer.cornerCurve = .continuous; $0.layer.masksToBounds = true })
        
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowRadius = 30
        view.layer.shadowOpacity = 0.4
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var grabberView: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor.secondarySystemFill
        view.layer.cornerRadius = 25
        
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.8
        
        let pointerInteraction = UIPointerInteraction(delegate: self)
        view.addInteraction(pointerInteraction)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var backgroundView: SBAVisualEffectView = {
        let view = SBAVisualEffectView(blurStyle: .systemUltraThinMaterial)
        
        view.frame = self.view.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return view
    }()
    
    lazy var grabberCenterXAnchor: NSLayoutConstraint = grabberView.centerXAnchor.constraint(equalTo: meshView.centerXAnchor)
    lazy var grabberCenterYAnchor: NSLayoutConstraint = grabberView.centerYAnchor.constraint(equalTo: meshView.centerYAnchor)
    
    lazy var meshService: MeshService! = {
        (view.window?.windowScene?.delegate as? SceneDelegate)?.meshService
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.backgroundColor = UIColor.systemBackground
        
#if targetEnvironment(macCatalyst)
        view.addSubview(backgroundView)
#endif
        view.addSubview(meshView)
        view.addSubview(grabberView)
        
        NSLayoutConstraint.activate([
            meshView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            meshView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            meshView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            meshView.widthAnchor.constraint(equalTo: meshView.heightAnchor),
            
            grabberCenterXAnchor,
            grabberCenterYAnchor,
            grabberView.widthAnchor.constraint(equalToConstant: 50),
            grabberView.heightAnchor.constraint(equalTo: grabberView.widthAnchor)
        ])
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            meshView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        } else {
            meshView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(updateGesture))
        panGesture.allowedScrollTypesMask = [.all]
        
        grabberView.addGestureRecognizer(panGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        meshService.$colors
            .sink { [weak self] colors in
                self?.meshView.create(colors, subdivisions: self?.meshService.subdivsions ?? 18)
            }
            .store(in: &cancellables)
        
        meshService.$subdivsions
            .sink { [weak self] subdivions in
                self?.meshView.create(self?.meshService.colors ?? [], subdivisions: subdivions)
            }
            .store(in: &cancellables)
        
        meshService.$contentScaleFactor
            .sink { [weak self] contentScaleFactor in
                self?.meshView.scaleFactor = CGFloat(contentScaleFactor)
            }
            .store(in: &cancellables)
        
        meshService.$isRenderingAsWireframe
            .sink { [weak self] isRenderingAsWireframe in
                self?.meshView.debugOptions = isRenderingAsWireframe ? [.renderAsWireframe] : []
            }
            .store(in: &cancellables)
        
        if meshService.colors.isEmpty {
            meshService.colors = [
                .init(point: (0, 0), location: (0, 0), color: UIColor(red: 0.149, green: 0.275, blue: 0.325, alpha: 1.000)),
                .init(point: (0, 1), location: (0, 1), color: UIColor(red: 0.157, green: 0.447, blue: 0.443, alpha: 1.000)),
                .init(point: (0, 2), location: (0, 2), color: UIColor(red: 0.165, green: 0.616, blue: 0.561, alpha: 1.000)),
                
                .init(point: (1, 0), location: (1, 0), color: UIColor(red: 0.541, green: 0.694, blue: 0.490, alpha: 1.000)),
                .init(point: (1, 1), location: (1, 1), color: UIColor(red: 0.541, green: 0.694, blue: 0.490, alpha: 1.000)),
                .init(point: (1, 2), location: (1, 2), color: UIColor(red: 0.914, green: 0.769, blue: 0.416, alpha: 1.000)),
                
                .init(point: (2, 0), location: (2, 0), color: UIColor(red: 0.957, green: 0.635, blue: 0.380, alpha: 1.000)),
                .init(point: (2, 1), location: (2, 1), color: UIColor(red: 0.933, green: 0.537, blue: 0.349, alpha: 1.000)),
                .init(point: (2, 2), location: (2, 2), color: UIColor(red: 0.906, green: 0.435, blue: 0.318, alpha: 1.000)),
            ]
        }
    }
    
    @objc func updateGesture(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: meshView)
        
        let xLocation = location.x - (meshView.bounds.width / 2)
        let minXLocation = max(xLocation, -meshView.bounds.width / 2)
        let maxXLocation = min(minXLocation, meshView.bounds.width / 2)
        grabberCenterXAnchor.constant = maxXLocation
        
        let yLocation = location.y - (meshView.bounds.height / 2)
        let minYLocation = max(yLocation, -meshView.bounds.height / 2)
        let maxYLocation = min(minYLocation, meshView.bounds.height / 2)
        grabberCenterYAnchor.constant = maxYLocation
        
        UIView.animate(withDuration: 0.05, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction, .curveLinear]) {
            self.view.layoutSubviews()
        }
        
        let x = min(1.8, max(0.3, location.x / (meshView.bounds.width / 2)))
        let y = 2 - min(1.5, max(0.35, location.y / (meshView.bounds.height / 2)))
        
        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            let meshService = sceneDelegate.meshService
            
            if let index = meshService.colors.firstIndex(where: { $0.point.x == 1 && $0.point.y == 1 }) {
                meshService.colors[index].location = (Float(x), Float(y))
            }
        }
    }
}

extension EditorViewController: UIPointerInteractionDelegate {
#if !targetEnvironment(macCatalyst)
    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        return .hidden()
    }
#endif
}
