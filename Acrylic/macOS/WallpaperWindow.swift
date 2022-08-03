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
    private lazy var viewModel: FluidViewModel? = {
        let viewModel = FluidViewModel()
        viewModel.shouldUpdateDesktopPicture = true
        return viewModel
    }()
    
    init() {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 480, height: 300), styleMask: [.borderless, .fullSizeContentView], backing: .buffered, defer: false)
        isReleasedWhenClosed = true
        level = .init(Int(CGWindowLevelForKey(.desktopWindow)))
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        ignoresMouseEvents = true
        isOpaque = false
        hasShadow = false
        backgroundColor = .clear
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        
        if let viewModel {
            let screenSaverView = ScreenSaverView().environmentObject(viewModel)
            contentView = NSHostingView(rootView: screenSaverView)
        }
        
        updateScreenSize()
        NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main) { [weak self] _ in
            self?.updateScreenSize()
        }
    }
    
    override func close() {
        contentView = nil
        viewModel?.destroy()
        viewModel = nil
        super.close()
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
