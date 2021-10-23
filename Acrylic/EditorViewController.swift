//
//  EditorViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import UIKit

class EditorViewController: UIViewController {
    
    lazy var meshView: MeshView = {
        let view = MeshView()
        
        view.create([])
        
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
            self.meshView.create([])
        }
    }
}

