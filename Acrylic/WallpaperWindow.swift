//
//  WallpaperWindow.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 7/31/22.
//

import Foundation

#if os(macOS)
import AppKit
import SwiftUI

class AppWindow: NSWindow {
    init() {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 480, height: 300), styleMask: [.borderless], backing: .buffered, defer: true)
        makeKeyAndOrderFront(nil)
        isReleasedWhenClosed = false
        styleMask.insert(NSWindow.StyleMask.fullSizeContentView)
        title = "title placeholder"
        contentView = NSHostingView(rootView: ScreenSaverView())
        level = .init(-1000)
        
        updateScreenSize()
        NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main) { [weak self] _ in
            self?.updateScreenSize()
        }
    }
    
    func updateScreenSize() {
        if let screenSize = screen?.frame {
            setFrame(screenSize, display: true)
        }
    }
}
#endif
