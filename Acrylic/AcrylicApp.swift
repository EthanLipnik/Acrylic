//
//  AcrylicApp.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 7/28/22.
//

import SwiftUI

@main
struct AcrylicApp: App {
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
                .frame(minWidth: 640, minHeight: 480)
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
#endif
    }
    
#if os(macOS)
    func menuBarExtra() -> some Scene {
        if #available(macOS 13.0, *) {
            return MenuBarExtra {
                Button("Start Animating Wallpaper...") {
                    let window = AppWindow()
                    window.makeKeyAndOrderFront(nil)
                    let windowController = NSWindowController(window: window)
                    windowController.showWindow(nil)
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
