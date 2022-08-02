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
    private var colors: MeshGrid? = nil
    
    init() {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 480, height: 300), styleMask: [.borderless], backing: .buffered, defer: true)
        makeKeyAndOrderFront(nil)
        isReleasedWhenClosed = false
        styleMask.insert(NSWindow.StyleMask.fullSizeContentView)
        title = "title placeholder"
        level = .init(-2147483623)
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        ignoresMouseEvents = true
        
        let screenSaverView = ScreenSaverView { [weak self] grid in
            self?.colors = grid
            self?.updateBackgroundImage()
        }
        contentView = NSHostingView(rootView: screenSaverView)
        
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
    
    @objc
    func updateBackgroundImage() {
        var color: NSColor?
        
        if (UserDefaults.standard.object(forKey: "shouldColorMatchWallpaperMenuBar") as? Bool) ?? true {
            if let colors = self.colors {
               color = colors.elements.first?.color
            }
        } else {
            color = .black
        }
        
        guard let color else { return }
        
        do {
            let image = NSImage(color: color, size: NSSize(width: 10, height: 10))
            guard let imageData = image.pngData else { return }
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("background \(Date())")
            if FileManager.default.fileExists(atPath: url.path) {
                try? FileManager.default.removeItem(at: url)
            }
            try imageData.write(to: url)
            
            let workspace = NSWorkspace.shared
            if let screen = NSScreen.main {
                try workspace.setDesktopImageURL(url, for: screen)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                try? FileManager.default.removeItem(at: url)
            }
        } catch {
            print(error)
        }
    }
    
    override var canBecomeKey: Bool {
        return false
    }
    
    override var canBecomeMain: Bool {
        return false
    }
}

extension NSImage {
    convenience init(color: NSColor, size: NSSize) {
        self.init(size: size)
        lockFocus()
        color.drawSwatch(in: NSRect(origin: .zero, size: size))
        unlockFocus()
    }
    
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .tiff, properties: [:])
    }
    
    func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        do {
            try pngData?.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
}
#endif
