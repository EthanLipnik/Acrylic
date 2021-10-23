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
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.systemBackground
        
        view.addSubview(meshView)
        NSLayoutConstraint.activate([
            meshView.topAnchor.constraint(equalTo: view.topAnchor),
            meshView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            meshView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            meshView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.meshView.create([
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
        }
    }
}

