//
//  WallpaperService.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/4/22.
//

#if os(macOS)
import Foundation
import AppKit

class WallpaperService: ObservableObject {
    static let shared = WallpaperService.init()
    
    private lazy var window: WallpaperWindow? = nil
    private lazy var windowController: NSWindowController? = nil
    private lazy var currentDesktopPictureUrl: URL? = nil
    
    var isUsingWallpaper: Bool {
        return window != nil || windowController != nil
    }
    
    init() {
        currentDesktopPictureUrl = getDesktopPicture()
    }
    
    @discardableResult
    func toggle(_ wallpaper: WallpaperWindow.WallpaperType) -> Bool {
        let isUsingWallpaper = self.isUsingWallpaper
        
        windowController?.close()
        windowController = nil
        window = nil
        
        guard !isUsingWallpaper else {
            do {
                try revertDesktopPicture()
            } catch {
                print("Failed to revert desktop picture", error)
            }
            
            return false
        }
        
        switch wallpaper {
        case .fluid:
            let window = FluidWindow()
            windowController = NSWindowController(window: window)
            windowController?.showWindow(nil)
            self.window = window
            
            return true
        case .video:
            let window = VideoWindow()
            windowController = NSWindowController(window: window)
            windowController?.showWindow(nil)
            self.window = window
            
            return true
        default:
            break
        }
        
        return false
    }
    
    func refresh() {
        if let fluidWindow = window as? FluidWindow {
            fluidWindow.viewModel?.newPalette()
            fluidWindow.viewModel?.setTimer()
        }
    }
    
    func revertDesktopPicture() throws {
        let workspace = NSWorkspace.shared
        guard let screen = NSScreen.main, let currentDesktopPictureUrl, currentDesktopPictureUrl != getDesktopPicture() else { return }
        try workspace.setDesktopImageURL(currentDesktopPictureUrl, for: screen)
    }
    
    func getDesktopPicture() -> URL? {
        let workspace = NSWorkspace.shared
        if let screen = NSScreen.main {
            return workspace.desktopImageURL(for: screen)
        }
        
        return nil
    }
}
#endif
