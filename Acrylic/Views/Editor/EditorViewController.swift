//
//  EditorViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/29/22.
//

import UIKit
import SwiftUI
import Hero

class EditorViewController<Document: UIDocument>: UISplitViewController {

    let document: Document

    var editorViewControllers: [UISplitViewController.Column: UIViewController] {
        didSet {
            setViewController(editorViewControllers[.primary], for: .primary)
            setViewController(editorViewControllers[.secondary], for: .secondary)
            setViewController(editorViewControllers[.compact], for: .compact)
        }
    }

    init(_ document: Document, viewControllers: [UISplitViewController.Column: UIViewController] = [:]) {
        self.document = document
        self.editorViewControllers = viewControllers
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

        hero.isEnabled = UIDevice.current.userInterfaceIdiom != .mac
    }

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
