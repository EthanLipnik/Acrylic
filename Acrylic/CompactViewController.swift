//
//  CompactViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/24/21.
//

import UIKit

class CompactViewController: UIViewController {
    let editorVC = EditorViewController()
    let optionsVC = OptionsViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(editorVC.view)
        editorVC.view.frame = view.bounds
        editorVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        editorVC.didMove(toParent: self)
        
        view.addSubview(optionsVC.view)
        optionsVC.view.translatesAutoresizingMaskIntoConstraints = false
        optionsVC.didMove(toParent: self)
        
        optionsVC.view.backgroundColor = UIColor.systemGroupedBackground
        optionsVC.view.layer.cornerRadius = 30
        optionsVC.view.layer.cornerCurve = .continuous
        
        NSLayoutConstraint.activate([
            optionsVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            optionsVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            optionsVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            optionsVC.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
    }
}
