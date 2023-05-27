//
//  WallpaperService.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/4/22.
//

import AppKit
import Foundation

@MainActor
class WallpaperService: ObservableObject {
    static let shared = WallpaperService()

    private lazy var window: WallpaperWindow? = nil
    private lazy var windowController: NSWindowController? = nil
    private lazy var currentDesktopPictureUrl: URL? = nil

    @Published
    var selectedWallpaper: WallpaperType?
    @Published
    var isLoading: Bool = false

    var isUsingWallpaper: Bool {
        window != nil || windowController != nil || selectedWallpaper != nil
    }

    init() {
        currentDesktopPictureUrl = getDesktopPicture()

        if UserDefaults.standard.bool(forKey: "shouldStartFWOnLaunch") {
            Task {
                do {
                    try await start(.fluid)
                } catch {
                    print(error)
                }
            }
        }
    }

    @discardableResult
    func toggle(_ wallpaper: WallpaperType) async throws -> Bool {
        let isUsingWallpaper = isUsingWallpaper

        if isUsingWallpaper {
            try await stop()
            return false
        } else {
            try await start(wallpaper)
            return true
        }
    }

    func start(_ wallpaper: WallpaperType) async throws {
        guard !isLoading else { throw CocoaError(.fileReadNoPermission) }

        isLoading = true
        try await stop()

        currentDesktopPictureUrl = getDesktopPicture()

        switch wallpaper {
        case .fluid, .nowPlaying:
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

        try await Task.sleep(nanoseconds: 1_000_000_000)

        isLoading = false
    }

    func stop() async throws {
        isLoading = true

        let isUsingWallpaper = isUsingWallpaper
        windowController?.close()
        windowController = nil
        window = nil

        selectedWallpaper = nil

        if isUsingWallpaper {
            try revertDesktopPicture()

            try await Task.sleep(nanoseconds: 2_000_000_000)
        }

        isLoading = false
    }

    func refresh() {
        if let fluidWindow = window as? FluidWindow {
            fluidWindow.viewModel?.newPalette()
            fluidWindow.viewModel?.setTimer()
        }
    }

    @MainActor
    func revertDesktopPicture() throws {
        let workspace = NSWorkspace.shared
        guard let screen = NSScreen.main, let currentDesktopPictureUrl,
              currentDesktopPictureUrl != getDesktopPicture() else { return }
        try workspace.setDesktopImageURL(currentDesktopPictureUrl, for: screen)
    }

    @MainActor
    func getDesktopPicture() -> URL? {
        let workspace = NSWorkspace.shared
        if let screen = NSScreen.main {
            return workspace.desktopImageURL(for: screen)
        }

        return nil
    }
}
