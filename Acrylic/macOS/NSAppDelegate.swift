//
//  NSAppDelegate.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 7/31/22.
//

#if os(macOS)
import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBar: StatusBarController?
    private var aboutBoxWindowController: NSWindowController?
    
    lazy var currentDesktopPictureUrl: URL? = nil
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
        
        statusBar = StatusBarController()
        statusBar?.appDelegate = self
        
        let launcherAppId = "com.ethanlipnik.Acrylic.LaunchApplication"
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == launcherAppId }.isEmpty
        
        if isRunning {
            DistributedNotificationCenter.default().post(name: .killLauncher, object: Bundle.main.bundleIdentifier!)
        }
        
        getDesktopPicture()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        try? revertDesktopPicture()
    }
    
    func revertDesktopPicture() throws {
        guard let currentDesktopPictureUrl else { return }
        let workspace = NSWorkspace.shared
        if let screen = NSScreen.main {
            try workspace.setDesktopImageURL(currentDesktopPictureUrl, for: screen)
        }
    }
    
    func getDesktopPicture() {
        let workspace = NSWorkspace.shared
        if let screen = NSScreen.main {
            self.currentDesktopPictureUrl = workspace.desktopImageURL(for: screen)
        }
    }
    
    func showAboutPanel() {
        if aboutBoxWindowController == nil {
            let styleMask: NSWindow.StyleMask = [.closable, .titled, .fullSizeContentView]
            let window = NSWindow()
            window.styleMask = styleMask
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.isMovableByWindowBackground = true
            window.contentView = NSHostingView(rootView: AboutView().frame(width: 300, height: 400))
            aboutBoxWindowController = NSWindowController(window: window)
        }
        
        aboutBoxWindowController?.showWindow(aboutBoxWindowController?.window)
    }
}
#endif
