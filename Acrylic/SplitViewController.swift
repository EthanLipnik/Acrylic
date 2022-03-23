//
//  SplitViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import UIKit
import SwiftUI

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredDisplayMode = .oneBesideSecondary
        primaryBackgroundStyle = .sidebar
        minimumPrimaryColumnWidth = 320
        maximumPrimaryColumnWidth = 320

        setViewController(UINavigationController(rootViewController: OptionsViewController()), for: .primary)
        setViewController(EditorViewController(), for: .secondary)
        setViewController(CompactViewController(), for: .compact)
        
        delegate = self
    }
    
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        svc.presentsWithGesture = displayMode != .oneBesideSecondary
    }
}
