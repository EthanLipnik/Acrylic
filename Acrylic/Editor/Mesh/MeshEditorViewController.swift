//
//  MeshEditorViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import UIKit
import SwiftUI

class MeshEditorViewController: EditorViewController<MeshDocument> {
    
    var meshService: MeshService
    
    init(_ document: MeshDocument) {
        self.meshService = .init(document)
        super.init(document, viewControllers: [:])
        
        let primaryViewController = UINavigationController(rootViewController: UIHostingController(rootView: MeshOptionsView { [weak self] in
            self?.dismiss(animated: true)
        }.environmentObject(meshService)))
        let compactViewController = UINavigationController(rootViewController: UIHostingController(rootView: MeshEditorCompactView { [weak self] in
            self?.dismiss(animated: true)
        }.environmentObject(meshService)))
        
        editorViewControllers = [
            .primary: primaryViewController,
            .secondary: MeshViewController(meshService),
            .compact: compactViewController
        ]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
