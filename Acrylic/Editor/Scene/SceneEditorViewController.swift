//
//  SceneEditorViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/29/22.
//

import UIKit

class SceneEditorViewController: EditorViewController<SceneDocument> {

    init(_ document: SceneDocument) {
        super.init(document, viewControllers: [:])
        
//        let primaryViewController = UINavigationController(rootViewController: UIHostingController(rootView: MeshOptionsView { [weak self] in
//            self?.dismiss(animated: true)
//        }))
//        let compactViewController = UINavigationController(rootViewController: UIHostingController(rootView: MeshEditorCompactView { [weak self] in
//            self?.dismiss(animated: true)
//        }.environmentObject(meshService)))
//        
//        editorViewControllers = [
//            .primary: primaryViewController,
//            .secondary: MeshViewController(meshService),
//            .compact: compactViewController
//        ]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
