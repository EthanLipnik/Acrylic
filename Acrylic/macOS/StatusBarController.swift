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
    var popover: NSPopover!

    init() {
        statusBar = NSStatusBar.system
        // Creating a status bar item having a fixed length
        statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)

        if let statusBarButton = statusItem.button {
            statusBarButton.image = NSImage(systemSymbolName: "paintbrush.fill", accessibilityDescription: nil)
            statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
            statusBarButton.image?.isTemplate = true
            statusBarButton.target = self
            statusBarButton.action = #selector(togglePopover(_:))
            
            let contentView = ContentView { [weak self] in
                self?.appDelegate?.showAboutPanel()
            }.frame(width: 300)
            let viewController = NSHostingController(rootView: contentView)
            let popover = NSPopover()
            popover.contentViewController = viewController
            popover.contentSize = NSSize(width: 300, height: 300)
            popover.behavior = .transient
            popover.setValue(true, forKeyPath: "shouldHideAnchor")
            popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
            self.popover = popover
        }
    }
    
    @objc
    func togglePopover(_ sender: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(sender)
            return
        }
        
        popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
        
        NotificationCenter.default.post(name: .init("didOpenStatusBarItem"), object: nil)
    }
    
    @objc
    func openAbout() {
        appDelegate?.showAboutPanel()
    }
}
#endif
