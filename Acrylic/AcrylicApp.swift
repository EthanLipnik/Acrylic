//
//  AcrylicApp.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 7/28/22.
//

import SwiftUI
import MeshKit

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
                .onAppear {
                    NSApp.setActivationPolicy(.regular)
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
        stableDiffusionWindow
    }

    var meshCreatorWindow: some Scene {
        WindowGroup("Mesh Creator") {
            DeepLinkMeshCreatorView()
                .navigationTitle("Acrylic – Mesh Creator")
                .frame(minWidth: 400, minHeight: 400)
                .onDisappear {
                    if NSApp.windows.compactMap(\.identifier).filter({ $0.rawValue.hasPrefix("SwiftUI") || $0.rawValue.hasPrefix("Acrylic") }).count == 0 {
                        NSApp.setActivationPolicy(.accessory)
                    }
                }
                .onAppear {
                    NSApp.setActivationPolicy(.regular)
                }
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: WindowManager.MeshCreator.rawValue))
        .windowToolbarStyle(.unifiedCompact)
    }
    
    var stableDiffusionWindow: some Scene {
        WindowGroup("Stable Diffusion") {
            StableDiffusionDownloaderView()
                .navigationTitle("Acrylic – Stable Diffusion")
                .frame(minWidth: 400, minHeight: 400)
                .onDisappear {
                    if NSApp.windows.compactMap(\.identifier).filter({ $0.rawValue.hasPrefix("SwiftUI") || $0.rawValue.hasPrefix("Acrylic") }).count == 0 {
                        NSApp.setActivationPolicy(.accessory)
                    }
                }
                .onAppear {
                    NSApp.setActivationPolicy(.regular)
                }
                .frame(width: 600, height: 480)
        }
        .windowResizability(.contentSize)
        .handlesExternalEvents(matching: Set(arrayLiteral: WindowManager.StableDiffusion.rawValue))
    }
    
    struct DeepLinkMeshCreatorView: View {
        @State private var size: MeshSize? = nil
        
        var body: some View {
            Group {
                if let size {
                    MeshCreatorView(size: size)
                } else {
                    ProgressView()
                        .onOpenURL { url in
                            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
                            if let sizeStr = urlComponents?.queryItems?.first(where: { $0.name == "size" })?.value, 
                                let size = Int(sizeStr) {
                                self.size = MeshSize(width: size, height: size)
                            }
                        }
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
    case StableDiffusion = "StableDiffusionView"

    func open(query: URLQueryItem...) {
        var urlComponents = URLComponents(string: urlStr)
        urlComponents?.queryItems = query
        if let url = urlComponents?.url {
            NSWorkspace.shared.open(url)
        }
    }
    
    func open() {
        if let url = URL(string: urlStr) {
            NSWorkspace.shared.open(url)
        }
    }
    
    var urlStr: String {
        return "acrylic://\(self.rawValue)"
    }
}
