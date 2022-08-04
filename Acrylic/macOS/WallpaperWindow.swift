//
//  WallpaperWindow.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 7/31/22.
//

import Foundation
import MeshKit

#if os(macOS)
import AppKit
import SwiftUI

class WallpaperWindow: NSWindow {
    enum WallpaperType {
        case fluid
        case video
        case unknown
    }
    
    var wallpaperType: WallpaperType { return .unknown }
    
    required init(view: some View) {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 480, height: 300), styleMask: [.borderless, .fullSizeContentView], backing: .buffered, defer: false)
        isReleasedWhenClosed = true
        level = .init(Int(CGWindowLevelForKey(.desktopWindow)))
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenNone]
        ignoresMouseEvents = true
        isOpaque = false
        hasShadow = false
        backgroundColor = .clear
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        
        
        contentView = NSHostingView(rootView: view)
        
        updateScreenSize()
        NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main) { [weak self] _ in
            self?.updateScreenSize()
        }
    }
    
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        return frameRect
    }
    
    func updateScreenSize() {
        if let screenSize = screen?.frame {
            setFrame(screenSize, display: true)
        }
    }
    
    override var canBecomeKey: Bool {
        return false
    }
    
    override var canBecomeMain: Bool {
        return false
    }
}
#endif
