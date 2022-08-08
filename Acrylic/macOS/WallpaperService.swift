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
    
    @Published var selectedWallpaper: WallpaperType? = nil
    
    var isUsingWallpaper: Bool {
        return window != nil || windowController != nil || selectedWallpaper != nil
    }
    
    init() {
        currentDesktopPictureUrl = getDesktopPicture()
        
        if UserDefaults.standard.bool(forKey: "shouldStartFWOnLaunch") {
            Task(priority: .userInitiated) {
                do {
                    try await toggle(.fluid)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    @discardableResult
    func toggle(_ wallpaper: WallpaperType) async throws -> Bool {
        let isUsingWallpaper = self.isUsingWallpaper
        
        try await disable()
        
        guard !isUsingWallpaper else { return false }
        
        try await enable(wallpaper)
        
        return true
    }
    
    func enable(_ wallpaper: WallpaperType) async throws {
        try await disable()
        
        currentDesktopPictureUrl = getDesktopPicture()
        
        switch wallpaper {
        case .fluid:
            let window = await FluidWindow()
            windowController = await NSWindowController(window: window)
            self.window = window
        case .video:
            let window = await VideoWindow()
            windowController = await NSWindowController(window: window)
            self.window = window
        }
        
        await windowController?.showWindow(nil)
        
        DispatchQueue.main.async { [weak self] in
            self?.selectedWallpaper = wallpaper
        }
    }
    
    func disable() async throws {
        let isUsingWallpaper = self.isUsingWallpaper
        await windowController?.close()
        windowController = nil
        window = nil
        
        DispatchQueue.main.async { [weak self] in
            self?.selectedWallpaper = nil
        }
        
        if isUsingWallpaper {
            try revertDesktopPicture()
            try await Task.sleep(nanoseconds: 5_000_000_000)
        }
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
