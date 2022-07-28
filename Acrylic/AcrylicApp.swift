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
    }
}
