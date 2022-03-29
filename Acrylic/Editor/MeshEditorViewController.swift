//
//  MeshEditorViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import UIKit
import SwiftUI

class MeshEditorViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    var meshService: MeshService = .init()
    
    init(_ document: MeshDocument) {
        self.meshService = .init(document)
        super.init(style: .doubleColumn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredDisplayMode = .oneBesideSecondary
        primaryBackgroundStyle = .sidebar
        minimumPrimaryColumnWidth = 320
        maximumPrimaryColumnWidth = 320

        setViewController(UINavigationController(rootViewController: UIHostingController(rootView: MeshOptionsView { [weak self] in
            self?.dismiss(animated: true)
        }.environmentObject(meshService))), for: .primary)
        setViewController(MeshViewController(meshService), for: .secondary)
        setViewController(UINavigationController(rootViewController: UIHostingController(rootView: MeshEditorCompactView { [weak self] in
            self?.dismiss(animated: true)
        }.environmentObject(meshService))), for: .compact)
        
        delegate = self
    }
    
//    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
//        svc.presentsWithGesture = displayMode != .oneBesideSecondary
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
#if targetEnvironment(macCatalyst)
        (viewController(for: .primary) as? UINavigationController)?.topViewController?.view.backgroundColor = UIColor.clear
        (viewController(for: .primary) as? UINavigationController)?.setNavigationBarHidden(true, animated: false)
#else
        (viewController(for: .primary) as? UINavigationController)?.topViewController?.view.backgroundColor = UIColor.secondarySystemBackground
#endif
    }
}
