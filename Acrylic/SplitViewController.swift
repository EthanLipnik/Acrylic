//
//  SplitViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import UIKit

class SplitViewController: UISplitViewController {
    
    let editorVC = EditorViewController()
    let optionsVC = OptionsViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredDisplayMode = .oneBesideSecondary
        primaryBackgroundStyle = .sidebar

        setViewController(optionsVC, for: .primary)
        setViewController(editorVC, for: .secondary)
    }
}
