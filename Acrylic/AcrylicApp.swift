//
//  AcrylicApp.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 7/28/22.
//

import SwiftUI

#if !os(tvOS)
@main
struct AcrylicApp: App {
    @Environment(\.openURL) var openUrl
    
#if os(macOS)
    @NSApplicationDelegateAdaptor var appDelegate: AppDelegate
#endif
    
    var body: some Scene {
#if os(macOS)
        WindowGroup {
            ContentView {
                appDelegate.showAboutPanel()
            }
            .navigationTitle("Acrylic")
            .frame(width: 300, height: 350)
        }.windowStyle(.hiddenTitleBar)
        
        WindowGroup("Videos") {
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
#endif
        
        meshCreatorWindow
    }
    
    var meshCreatorWindow: some Scene {
        WindowGroup("Mesh Creator") {
#if os(iOS)
            NavigationView {
                MeshCreatorView()
                    .navigationTitle("Acrylic")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .navigationViewStyle(.stack)
#else
            MeshCreatorView()
                .navigationTitle("Acrylic – Mesh Creator")
                .frame(minWidth: 400, minHeight: 400)
                .onDisappear {
                    if NSApp.windows.compactMap(\.identifier).filter({ $0.rawValue.hasPrefix("SwiftUI") || $0.rawValue.hasPrefix("Acrylic") }).count == 0 {
                        NSApp.setActivationPolicy(.accessory)
                    }
                }
#endif
        }
#if os(macOS)
        .handlesExternalEvents(matching: Set(arrayLiteral: WindowManager.MeshCreator.rawValue))
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
            aboutCommand
#endif
        }
    }
    
#if os(macOS)
    var aboutCommand: CommandGroup<Button<Text>> {
        CommandGroup(replacing: .appInfo) {
            Button(action: {
                appDelegate.showAboutPanel()
            }) {
                Text("About Acrylic")
            }
        }
    }
#endif
}

#if os(macOS)
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
#endif
#endif
