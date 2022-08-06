//
//  StatusBarController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/1/22.
//

#if os(macOS)
import AppKit

final class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    
    private lazy var wallpaperService = WallpaperService.shared
    
    private lazy var toggleFluidItem: NSMenuItem = {
        let toggleWallpaperItem = NSMenuItem(title: "Start Fluid Wallpaper", action: #selector(toggleAnimatingWallpaper), keyEquivalent: "")
        toggleWallpaperItem.target = self
        return toggleWallpaperItem
    }()
    private lazy var toggleVideoItem: NSMenuItem = {
        let toggleWallpaperItem = NSMenuItem(title: "Start Video Wallpaper", action: #selector(toggleVideoWallpaper), keyEquivalent: "")
        toggleWallpaperItem.target = self
        return toggleWallpaperItem
    }()
    
    weak var appDelegate: AppDelegate?

    init() {
        statusBar = NSStatusBar.system
        // Creating a status bar item having a fixed length
        statusItem = statusBar.statusItem(withLength: 28.0)
        statusItem.menu = createMenu()

        if let statusBarButton = statusItem.button {
            statusBarButton.image = NSImage(systemSymbolName: "paintbrush.fill", accessibilityDescription: nil)
            statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
            statusBarButton.image?.isTemplate = true
        }
        
        NotificationCenter.default.addObserver(forName: .init("didEnableVideoBackground"), object: nil, queue: .main) { [weak self] notification in
            self?.toggleFluidItem.title = "Start Fluid Wallpaper"
            self?.toggleFluidItem.menu?.items.first(where: { $0.title == "New Palette" })?.isEnabled = false
            self?.toggleFluidItem.isEnabled = false
            
            self?.toggleVideoItem.isEnabled = true
            self?.toggleVideoItem.title = "Stop Video Wallpaper"
        }
    }
    
    func createMenu() -> NSMenu {
        let menu = NSMenu(title: "Acrylic")
        menu.autoenablesItems = false
        
        let createMeshGradientItem = NSMenuItem(title: "Create Mesh Gradient", action: #selector(createMeshGradient), keyEquivalent: "n")
        createMeshGradientItem.target = self
        menu.addItem(createMeshGradientItem)
        
        menu.addItem(.separator())
        
        menu.addItem(toggleFluidItem)
        
        let newWallpaperPaletteItem = NSMenuItem(title: "New Palette", action: #selector(generateNewPalette), keyEquivalent: "")
        newWallpaperPaletteItem.target = self
        newWallpaperPaletteItem.isEnabled = false
        menu.addItem(newWallpaperPaletteItem)
        
        menu.addItem(.separator())
        
        menu.addItem(toggleVideoItem)
        
        let manageVideosItem = NSMenuItem(title: "Manage Videos...", action: #selector(openManageVideosWindow), keyEquivalent: "")
        manageVideosItem.target = self
        manageVideosItem.isEnabled = true
        menu.addItem(manageVideosItem)
        
        menu.addItem(.separator())
        
        let settingsTitle: String = {
            if #available(macOS 13.0, *) {
                return "Settings..."
            } else {
                return "Preferences..."
            }
        }()
        let settingsItem = NSMenuItem(title: settingsTitle, action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        let aboutItem = NSMenuItem(title: "About Acrylic", action: #selector(openAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        menu.addItem(.separator())
        
        let quitItem = NSMenuItem(title: "Quit Acrylic", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        if UserDefaults.standard.bool(forKey: "shouldStartFWOnLaunch") {
            toggleAnimatingWallpaper()
        }
        
        return menu
    }
    
    @objc
    func createMeshGradient() {
        WindowManager.Main.open()
    }
    
    @objc
    func toggleAnimatingWallpaper() {
        if wallpaperService.toggle(.fluid) {
            toggleFluidItem.title = "Stop Fluid Wallpaper"
            toggleFluidItem.menu?.items.first(where: { $0.title == "New Palette" })?.isEnabled = true
            toggleVideoItem.isEnabled = false
        } else {
            toggleFluidItem.title = "Start Fluid Wallpaper"
            toggleFluidItem.menu?.items.first(where: { $0.title == "New Palette" })?.isEnabled = false
            toggleVideoItem.isEnabled = true
        }
    }
    
    @objc func generateNewPalette() {
        wallpaperService.refresh()
    }
    
    @objc func toggleVideoWallpaper() {
        if wallpaperService.toggle(.video) {
            toggleVideoItem.title = "Stop Video Wallpaper"
            toggleFluidItem.isEnabled = false
        } else {
            toggleVideoItem.title = "Start Video Wallpaper"
            toggleFluidItem.isEnabled = true
        }
    }
    
    @objc func openManageVideosWindow() {
        WindowManager.Videos.open()
    }
    
    @objc
    func openSettings() {
        if #available(macOS 13.0, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }
    
    @objc
    func openAbout() {
        appDelegate?.showAboutPanel()
    }
    
    @objc
    func quitApp() {
        NSApplication.shared.terminate(self)
    }
}
#endif
