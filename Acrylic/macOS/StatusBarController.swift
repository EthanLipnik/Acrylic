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
    
    private lazy var wallpaperService = WallpaperService()
    
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
    }
    
    func createMenu() -> NSMenu {
        let menu = NSMenu(title: "Acrylic")
        menu.autoenablesItems = false
        
        let createMeshGradientItem = NSMenuItem(title: "Create Mesh Gradient", action: #selector(openWindow), keyEquivalent: "n")
        createMeshGradientItem.target = self
        menu.addItem(createMeshGradientItem)
        
        menu.addItem(.separator())
        
        let toggleWallpaperItem = NSMenuItem(title: "Enable Fluid Wallpaper", action: #selector(toggleAnimatingWallpaper(_:)), keyEquivalent: "")
        toggleWallpaperItem.target = self
        menu.addItem(toggleWallpaperItem)
        
        let newWallpaperPaletteItem = NSMenuItem(title: "New Palette", action: #selector(generateNewPalette), keyEquivalent: "")
        newWallpaperPaletteItem.target = self
        newWallpaperPaletteItem.isEnabled = false
        menu.addItem(newWallpaperPaletteItem)
        
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
            toggleAnimatingWallpaper(toggleWallpaperItem)
        }
        
        return menu
    }
    
    @objc
    func openWindow() {
        guard let url = URL(string: "acrylic://") else { return }
        NSWorkspace.shared.open(url)
    }
    
    @objc
    func toggleAnimatingWallpaper(_ sender: NSMenuItem) {
        if wallpaperService.toggle(.fluid) {
            sender.title = "Disable Fluid Wallpaper"
            sender.menu?.items.first(where: { $0.title == "New Palette" })?.isEnabled = true
        } else {
            sender.title = "Enable Fluid Wallpaper"
            sender.menu?.items.first(where: { $0.title == "New Palette" })?.isEnabled = false
        }
    }
    
    @objc func generateNewPalette() {
        wallpaperService.refresh()
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
