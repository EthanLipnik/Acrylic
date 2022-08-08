//
//  StatusBarController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/1/22.
//

#if os(macOS)
import AppKit
import SwiftUI

final class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    
    weak var appDelegate: AppDelegate?

    init() {
        statusBar = NSStatusBar.system
        // Creating a status bar item having a fixed length
        statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)

        if let statusBarButton = statusItem.button {
            statusBarButton.image = NSImage(systemSymbolName: "paintbrush.fill", accessibilityDescription: nil)
            statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
            statusBarButton.image?.isTemplate = true
            statusBarButton.target = self
            statusBarButton.action = #selector(showPopover(_:))
        }
    }
    
    @objc
    func showPopover(_ sender: NSStatusBarButton) {
        let contentView = ContentView { [weak self] in
            self?.appDelegate?.showAboutPanel()
        }.frame(width: 300)
        let viewController = NSHostingController(rootView: contentView)
        let popover = NSPopover()
        popover.contentViewController = viewController
        popover.contentSize = NSSize(width: 300, height: 400)
        popover.behavior = .transient
        popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
    }
    
    @objc
    func openAbout() {
        appDelegate?.showAboutPanel()
    }
}
#endif
