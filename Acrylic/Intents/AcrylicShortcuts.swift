//
//  AcrylicShortcuts.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 9/18/22.
//

import AppIntents
import Foundation

@available(iOS 16.0, macOS 13.0, *)
struct AcrylicShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GenerateMeshIntent(),
            phrases: [
                "Generate an \(.applicationName) mesh",
                "Generate an \(.applicationName) \(\.$palette) mesh"
            ],
            shortTitle: "Generate a mesh",
            systemImageName: "square.stack.3d.down.right.fill"
        )
    }
}
