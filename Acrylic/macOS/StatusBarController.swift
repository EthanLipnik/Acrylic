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
    
    private var isUsingWallpaper: Bool = false
    private var wallpaperWindow: WallpaperWindow? = nil

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
        
        if UserDefaults.standard.bool(forKey: "shouldStartFWOnLaunch") {
            toggleAnimatingWallpaper()
        }
    }
    
    func createMenu() -> NSMenu {
        let menu = NSMenu(title: "Acrylic")
        
        let createMeshGradientItem = NSMenuItem(title: "Create Mesh Gradient", action: #selector(openWindow), keyEquivalent: "n")
        createMeshGradientItem.target = self
        menu.addItem(createMeshGradientItem)
        
        let toggleWallpaperItem = NSMenuItem(title: "Toggle Fluid Wallpaper", action: #selector(toggleAnimatingWallpaper), keyEquivalent: "")
        toggleWallpaperItem.target = self
        menu.addItem(toggleWallpaperItem)
        
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
        
        return menu
    }
    
    @objc
    func openWindow() {
        guard let url = URL(string: "acrylic://") else { return }
        NSWorkspace.shared.open(url)
    }
    
    @objc
    func toggleAnimatingWallpaper() {
        wallpaperWindow?.close()
        guard !isUsingWallpaper else { isUsingWallpaper = false; return }
        
        let window = WallpaperWindow()
        window.makeKeyAndOrderFront(nil)
        let windowController = NSWindowController(window: window)
        windowController.showWindow(nil)
        
        self.wallpaperWindow = window
        isUsingWallpaper  = true
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
    }
    
    @objc
    func quitApp() {
        NSApplication.shared.terminate(self)
    }
}
#endif
