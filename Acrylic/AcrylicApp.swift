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
    @State var isUsingWallpaper: Bool = false
    @State var wallpaperWindow: WallpaperWindow? = nil
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
                .frame(minWidth: 400, idealWidth: 400)
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
        menuBarExtra()
        
        Settings {
            Text("Hey")
                .frame(width: 300, height: 200)
        }
#endif
    }
    
#if os(macOS)
    func menuBarExtra() -> some Scene {
        if #available(macOS 13.0, *) {
            return MenuBarExtra {
                Button("Create Mesh Gradient...") {
                    if let url = URL(string: "acrylic://") {
                        openUrl(url)
                    }
                }
                
                Button("Toggle Animating Wallpaper") {
                    wallpaperWindow?.close()
                    guard !isUsingWallpaper else { isUsingWallpaper = false; return }
                    
                    let window = WallpaperWindow()
                    window.makeKeyAndOrderFront(nil)
                    let windowController = NSWindowController(window: window)
                    windowController.showWindow(nil)
                    
                    self.wallpaperWindow = window
                    isUsingWallpaper  = true
                }
                
                Divider()
                
                if #available(macOS 13.0, *) {
                    Button("Settings...") {
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    }
                } else {
                    Button("Preferences...") {
                        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                    }
                }
                
                Button("About Acrylic") {
                    NSApp.sendAction(Selector(("showAboutWindow:")), to: nil, from: nil)
                }
                
                Divider()
                    
                Button("Quit Acrylic") {
                    NSApplication.shared.terminate(self)
                }
                .keyboardShortcut("q")
            } label: {
                Label("Acrylic", systemImage: "paintbrush.fill")
            }
        } else {
            return WindowGroup {
                
            }
        }
    }
#endif
}
