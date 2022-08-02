//
//  NSAppDelegate.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 7/31/22.
//

import Foundation

#if os(macOS)
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBar: StatusBarController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
        
        statusBar = StatusBarController()
        
        let launcherAppId = "com.ethanlipnik.Acrylic.LaunchApplication"
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == launcherAppId }.isEmpty
        
        if isRunning {
            DistributedNotificationCenter.default().post(name: .killLauncher, object: Bundle.main.bundleIdentifier!)
        }
    }
}
#endif
