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
    
    @NSApplicationDelegateAdaptor var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            VideosManagementView()
                .frame(minWidth: 700, minHeight: 500)
                .onDisappear {
                    if NSApp.windows.compactMap(\.identifier).filter({ $0.rawValue.hasPrefix("SwiftUI") || $0.rawValue.hasPrefix("Acrylic") }).count == 0 {
                        NSApp.setActivationPolicy(.accessory)
                    }
                }
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: WindowManager.Videos.rawValue))
        
        Settings {
            SettingsView()
                .frame(width: 400)
        }
        
        meshCreatorWindow
    }
    
    var meshCreatorWindow: some Scene {
        WindowGroup("Mesh Creator") {
            MeshCreatorView()
                .navigationTitle("Acrylic – Mesh Creator")
                .frame(minWidth: 400, minHeight: 400)
                .onDisappear {
                    if NSApp.windows.compactMap(\.identifier).filter({ $0.rawValue.hasPrefix("SwiftUI") || $0.rawValue.hasPrefix("Acrylic") }).count == 0 {
                        NSApp.setActivationPolicy(.accessory)
                    }
                }
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: WindowManager.MeshCreator.rawValue))
        .windowToolbarStyle(.unifiedCompact)
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

            CommandGroup(replacing: .appInfo) {
                Button(action: {
                    appDelegate.showAboutPanel()
                }) {
                    Text("About Acrylic")
                }
            }
        }
    }
}

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

enum WindowManager: String, CaseIterable {
    case Main = "MainView"
    case MeshCreator = "MeshCreatorView"
    case Videos = "VideosView"
    
    func open(){
        if let url = URL(string: "acrylic://\(self.rawValue)") {
            NSWorkspace.shared.open(url)
        }
    }
}
