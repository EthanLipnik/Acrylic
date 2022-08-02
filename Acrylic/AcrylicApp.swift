//
//  AcrylicApp.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 7/28/22.
//

import SwiftUI

@main
struct AcrylicApp: App {
    @Environment(\.openURL) var openUrl
    
#if os(macOS)
    @NSApplicationDelegateAdaptor var appDelegate: AppDelegate
    
    init() {
        let launcherAppId = "com.ethanlipnik.Acrylic.LaunchApplication"
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == launcherAppId }.isEmpty
        
        if isRunning {
            DistributedNotificationCenter.default().post(name: .killLauncher, object: Bundle.main.bundleIdentifier!)
        }
    }
#endif
    
    var body: some Scene {
#if !os(tvOS)
        WindowGroup {
#if os(iOS)
            NavigationView {
                ContentView()
                    .navigationTitle("Acrylic")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .navigationViewStyle(.stack)
#else
            ContentView()
                .frame(minWidth: 400, minHeight: 400)
                .onAppear {
                    NSApp.setActivationPolicy(.regular)
                }
                .onDisappear {
                    if NSApp.windows.count <= 3 {
                        NSApp.setActivationPolicy(.accessory)
                    }
                }
#endif
        }
#if os(macOS)
        .windowToolbarStyle(.unifiedCompact)
#endif
        .commands {
            ToolbarCommands()
            
            CommandGroup(after: .newItem) {
                Button("Info...") {
                    
                }
                .keyboardShortcut("i")
                
                Divider()
                
                Button("Export...") {
                    
                }
                .keyboardShortcut("e")
            }
        }
        
        WindowGroup("Screen Saver") {
            ScreenSaverView()
                .frame(minWidth: 640, minHeight: 480)
        }
#if os(macOS)
        .windowStyle(.hiddenTitleBar)
#endif
#else
        WindowGroup {
            ScreenSaverView()
        }
#endif
        
#if os(macOS)
        Settings {
            SettingsView()
                .frame(width: 400, height: 600)
        }
#endif
    }
}

#if os(macOS)
extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}
#endif
