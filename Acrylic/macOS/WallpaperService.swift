//
//  WallpaperService.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/4/22.
//

#if os(macOS)
import Foundation
import AppKit

@MainActor
class WallpaperService: ObservableObject {
    static let shared = WallpaperService.init()
    
    private lazy var window: WallpaperWindow? = nil
    private lazy var windowController: NSWindowController? = nil
    private lazy var currentDesktopPictureUrl: URL? = nil
    
    @Published var selectedWallpaper: WallpaperType? = nil
    @Published var isLoading: Bool = false
    
    var isUsingWallpaper: Bool {
        return window != nil || windowController != nil || selectedWallpaper != nil
    }
    
    init() {
        currentDesktopPictureUrl = getDesktopPicture()
        
        if UserDefaults.standard.bool(forKey: "shouldStartFWOnLaunch") {
            Task {
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
        
        isLoading = true
        try await stop()
        isLoading = true
        
        guard !isUsingWallpaper else { return false }
        
        try await start(wallpaper)
        return true
    }
    
    func start(_ wallpaper: WallpaperType) async throws {
        isLoading = true
        try await stop()
        
        currentDesktopPictureUrl = getDesktopPicture()
        
        switch wallpaper {
        case .fluid, .music:
            let window = FluidWindow()
            windowController = NSWindowController(window: window)
            self.window = window
        case .video:
            let window = VideoWindow()
            windowController = NSWindowController(window: window)
            self.window = window
        }
        
        windowController?.showWindow(nil)
        
        selectedWallpaper = wallpaper
        
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        isLoading = false
    }
    
    func stop() async throws {
        isLoading = true
        
        let isUsingWallpaper = self.isUsingWallpaper
        windowController?.close()
        windowController = nil
        window = nil
        
        selectedWallpaper = nil
        
        if isUsingWallpaper {
            try revertDesktopPicture()
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
        
        isLoading = false
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