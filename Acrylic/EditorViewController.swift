//
//  EditorViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import UIKit
import MeshKit

class EditorViewController: UIViewController {
    
    lazy var meshView: MeshView = {
        let view = MeshView()
        
        view.layer.cornerRadius = 30
        view.layer.cornerCurve = .continuous
        
        view.subviews.forEach({ $0.layer.cornerRadius = 30; $0.layer.cornerCurve = .continuous; $0.layer.masksToBounds = true })
        
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 30
        view.layer.shadowOpacity = 0.4
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.create([
            .init(point: (0, 0), location: (0, 0), color: UIColor(red: 0.149, green: 0.275, blue: 0.325, alpha: 1.000)),
            .init(point: (0, 1), location: (0, 1), color: UIColor(red: 0.157, green: 0.447, blue: 0.443, alpha: 1.000)),
            .init(point: (0, 2), location: (0, 2), color: UIColor(red: 0.165, green: 0.616, blue: 0.561, alpha: 1.000)),
            
            .init(point: (1, 0), location: (1, 0), color: UIColor(red: 0.541, green: 0.694, blue: 0.490, alpha: 1.000)),
            .init(point: (1, 1), location: (1, 1), color: UIColor(red: 0.541, green: 0.694, blue: 0.490, alpha: 1.000)),
            .init(point: (1, 2), location: (1, 2), color: UIColor(red: 0.914, green: 0.769, blue: 0.416, alpha: 1.000)),
            
            .init(point: (2, 0), location: (2, 0), color: UIColor(red: 0.957, green: 0.635, blue: 0.380, alpha: 1.000)),
            .init(point: (2, 1), location: (2, 1), color: UIColor(red: 0.933, green: 0.537, blue: 0.349, alpha: 1.000)),
            .init(point: (2, 2), location: (2, 2), color: UIColor(red: 0.906, green: 0.435, blue: 0.318, alpha: 1.000)),
        ])
        
        return view
    }()
    
    lazy var grabberView: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor.secondarySystemFill
        view.layer.cornerRadius = 25
        
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.8
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var grabberCenterXAnchor: NSLayoutConstraint = grabberView.centerXAnchor.constraint(equalTo: meshView.centerXAnchor)
    lazy var grabberCenterYAnchor: NSLayoutConstraint = grabberView.centerYAnchor.constraint(equalTo: meshView.centerYAnchor)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.backgroundColor = UIColor.systemBackground
        
        view.addSubview(meshView)
        view.addSubview(grabberView)
        
        NSLayoutConstraint.activate([
            meshView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            meshView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            meshView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            meshView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            meshView.widthAnchor.constraint(equalTo: meshView.heightAnchor),
            
            grabberCenterXAnchor,
            grabberCenterYAnchor,
            grabberView.widthAnchor.constraint(equalToConstant: 50),
            grabberView.heightAnchor.constraint(equalTo: grabberView.widthAnchor)
        ])
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(updateGesture))
        panGesture.allowedScrollTypesMask = [.all]
        
        grabberView.addGestureRecognizer(panGesture)
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
        
        UIView.animate(withDuration: 0.05) {
            self.view.layoutSubviews()
        }
        
        let x = min(1.8, max(0.2, location.x / (meshView.bounds.width / 2)))
        let y = 2 - min(1.5, max(0.2, location.y / (meshView.bounds.height / 2)))
        
        meshView.create([
            .init(point: (0, 0), location: (0, 0), color: UIColor(red: 0.149, green: 0.275, blue: 0.325, alpha: 1.000)),
            .init(point: (0, 1), location: (0, 1), color: UIColor(red: 0.157, green: 0.447, blue: 0.443, alpha: 1.000)),
            .init(point: (0, 2), location: (0, 2), color: UIColor(red: 0.165, green: 0.616, blue: 0.561, alpha: 1.000)),
            
            .init(point: (1, 0), location: (1, 0), color: UIColor(red: 0.541, green: 0.694, blue: 0.490, alpha: 1.000)),
            .init(point: (1, 1), location: (Float(x), Float(y)), color: UIColor(red: 0.541, green: 0.694, blue: 0.490, alpha: 1.000)),
            .init(point: (1, 2), location: (1, 2), color: UIColor(red: 0.914, green: 0.769, blue: 0.416, alpha: 1.000)),
            
            .init(point: (2, 0), location: (2, 0), color: UIColor(red: 0.957, green: 0.635, blue: 0.380, alpha: 1.000)),
            .init(point: (2, 1), location: (2, 1), color: UIColor(red: 0.933, green: 0.537, blue: 0.349, alpha: 1.000)),
            .init(point: (2, 2), location: (2, 2), color: UIColor(red: 0.906, green: 0.435, blue: 0.318, alpha: 1.000)),
        ])
    }
}
