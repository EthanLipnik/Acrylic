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
                .onDisappear {
                    if NSApp.windows.compactMap(\.identifier).filter({ $0.rawValue.hasPrefix("SwiftUI") || $0.rawValue.hasPrefix("Acrylic") }).count == 0 {
                        NSApp.setActivationPolicy(.accessory)
                    }
                }
#endif
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: WindowManager.Main.rawValue))
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

#if os(macOS)
            CommandGroup(replacing: .appInfo) {
                Button(action: {
                    appDelegate.showAboutPanel()
                }) {
                    Text("About Acrylic")
                }
            }
#endif
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
        WindowGroup("Videos") {
            VideosManagementView()
                .frame(minWidth: 700, minHeight: 480)
                .onDisappear {
                    if NSApp.windows.compactMap(\.identifier).filter({ $0.rawValue.hasPrefix("SwiftUI") || $0.rawValue.hasPrefix("Acrylic") }).count == 0 {
                        NSApp.setActivationPolicy(.accessory)
                    }
                }
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: WindowManager.Videos.rawValue))
        
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

enum WindowManager: String, CaseIterable {
    case Main = "MainView"
    case Videos = "VideosView"
    
    func open(){
        if let url = URL(string: "acrylic://\(self.rawValue)") {
            NSWorkspace.shared.open(url)
        }
    }
}
