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
        
        let optionsView = MeshOptionsView(isCompact: false) { [weak self] in
            if self?.presentingViewController == nil {
                if let session = self?.view.window?.windowScene?.session {
                    UIApplication.shared.requestSceneSessionDestruction(session, options: nil)
                }
            } else {
                self?.dismiss(animated: true)
            }
        }.environmentObject(meshService)
        
        editorViewControllers = [
            .primary: UINavigationController(rootViewController: UIHostingController(rootView: optionsView)),
            .secondary: MeshViewController(meshService),
            .compact: MeshCompactViewController(meshService)
        ]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
