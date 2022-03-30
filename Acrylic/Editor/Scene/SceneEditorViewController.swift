//
//  SceneEditorViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/29/22.
//

import UIKit

class SceneEditorViewController: EditorViewController<SceneDocument> {
    
    var sceneService: SceneService
    
    init(_ document: SceneDocument) {
        self.sceneService = .init(document)
        super.init(document, viewControllers: [:])
        
        editorViewControllers = [
            .primary: UIViewController(),
            .secondary: SceneViewController(sceneService),
            .compact: UIViewController()
        ]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
