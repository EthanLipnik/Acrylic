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
    @State private var isImportingVideo: Bool = false

    var body: some Scene {
        WindowGroup {
            VideosManagementView()
                .frame(minWidth: 700, minHeight: 500)
                .fileImporter(isPresented: $isImportingVideo, allowedContentTypes: [.movie], allowsMultipleSelection: true, onCompletion: { result in
                    do {
                        switch result {
                        case .success(let fileUrls):
                            Task(priority: .high) {
                                let downloadService = VideoDownloadService()
                                try await fileUrls.concurrentForEach { fileUrl in
                                    try await downloadService.importVideo(fileUrl)
                                }
                            }
                        case .failure(let error):
                            throw error
                        }
                    } catch {
                        print(error)
                    }
                })
                .onDisappear {
                    if NSApp.windows.compactMap(\.identifier).filter({ $0.rawValue.hasPrefix("SwiftUI") || $0.rawValue.hasPrefix("Acrylic") }).count == 0 {
                        NSApp.setActivationPolicy(.accessory)
                    }
                }
        }
        .commands {
            ToolbarCommands()
            SidebarCommands()

            CommandGroup(after: .newItem) {
                Button("Import Video...") {
                    isImportingVideo.toggle()
                }
                .keyboardShortcut("i")
            }

            CommandGroup(replacing: .appInfo) {
                Button(action: {
                    appDelegate.showAboutPanel()
                }) {
                    Text("About Acrylic")
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
    }
}

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

enum WindowManager: String, CaseIterable {
    case Main = "MainView"
    case MeshCreator = "MeshCreatorView"
    case Videos = "VideosView"

    func open() {
        if let url = URL(string: "acrylic://\(self.rawValue)") {
            NSWorkspace.shared.open(url)
        }
    }
}
