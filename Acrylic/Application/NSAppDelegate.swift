//
//  NSAppDelegate.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 7/31/22.
//

import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    static var statusBar: StatusBarController?
    private var aboutBoxWindowController: NSWindowController?

    func applicationDidFinishLaunching(_: Notification) {
        NSApplication.shared.windows.forEach { $0.close() }

        Self.statusBar = StatusBarController()
        Self.statusBar?.appDelegate = self

        NSApp.setActivationPolicy(.accessory)

        if !UserDefaults.standard.bool(forKey: "didShowOnboarding") {
            showOnboarding()
        }
    }

    @MainActor
    func applicationWillTerminate(_: Notification) {
        do {
            try WallpaperService.shared.revertDesktopPicture()
        } catch {
            print(error)
        }
    }

    func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
        false
    }

    func showAboutPanel() {
        if aboutBoxWindowController == nil {
            let styleMask: NSWindow.StyleMask = [.closable, .titled, .fullSizeContentView]
            let window = NSWindow()
            window.styleMask = styleMask
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.isMovableByWindowBackground = true
            window.contentView = NSHostingView(rootView: AboutView().frame(width: 300, height: 500))
            aboutBoxWindowController = NSWindowController(window: window)
        }

        aboutBoxWindowController?.showWindow(aboutBoxWindowController?.window)
        aboutBoxWindowController?.window?.makeKeyAndOrderFront(nil)
    }

    func showOnboarding() {
        let onboardingWindow = OnboardingWindow()
        let onboardingController = NSWindowController(window: onboardingWindow)
        onboardingController.showWindow(onboardingWindow)
        onboardingWindow.makeKeyAndOrderFront(onboardingController)
        onboardingWindow.center()
    }
}
