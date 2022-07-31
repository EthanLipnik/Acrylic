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
    
    @State var isUsingWallpaper: Bool = false
    @State var wallpaperWindow: WallpaperWindow? = nil
    
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
                    NSApp.setActivationPolicy(.accessory)
                }
#endif
        }
#if os(macOS)
        .windowToolbarStyle(.unifiedCompact)
#endif
        .commands {
            ToolbarCommands()
            
            CommandGroup(after: .newItem) {
                Divider()
                Menu("Randomize...") {
                    Button("Blue") {
                        
                    }
                    .keyboardShortcut(nil)
                    
                    Button("Red") {
                        
                    }
                    .keyboardShortcut(nil)
                    
                    Button("Rainbow") {
                        
                    }
                    .keyboardShortcut(nil)
                } primaryAction: {
                    
                }
                .keyboardShortcut("r")
                
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
                
                Divider()
                
                Button("Toggle Animating Wallpaper...") {
                    wallpaperWindow?.close()
                    guard !isUsingWallpaper else { isUsingWallpaper = false; return }
                    
                    let window = WallpaperWindow()
                    window.makeKeyAndOrderFront(nil)
                    let windowController = NSWindowController(window: window)
                    windowController.showWindow(nil)
                    
                    self.wallpaperWindow = window
                    isUsingWallpaper  = true
                }
                
                Button("Quit Acrylic") {
                    NSApplication.shared.terminate(self)
                }
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
