//
//  ContentView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/7/22.
//

import SwiftUI

#if os(macOS)
struct ContentView: View {
    @State private var selectedWallpaper: WallpaperType? = nil
    
    let openAbout: () -> Void
    @StateObject var wallpaperService: WallpaperService = WallpaperService.shared
    
    let popoverNotification = NotificationCenter.default
                .publisher(for: NSNotification.Name("didOpenStatusBarItem"))
    
    init(openAbout: @escaping () -> Void) {
        self.openAbout = openAbout
        
        let wallpaperService = WallpaperService.shared
        _selectedWallpaper = .init(initialValue: wallpaperService.selectedWallpaper)
        _wallpaperService = .init(wrappedValue: wallpaperService)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            LazyVGrid(columns: [.init(.adaptive(minimum: 100), spacing: 15)], spacing: 15) {
                ForEach([WallpaperType.fluid, WallpaperType.video], id: \.rawValue) { wallpaper in
                    let actions: [WallpaperItem.Action] = {
                        switch wallpaper {
                        case .video:
                            return [("Manage", {
                                WindowManager.Videos.open()
                            })]
                        default:
                            return []
                        }
                    }()
                    
                    WallpaperItem(wallpaper: wallpaper, selectedWallpaper: $selectedWallpaper, actions: actions) {
                        Task {
                            if selectedWallpaper == wallpaper {
                                withAnimation {
                                    selectedWallpaper = nil
                                }
                                try await wallpaperService.stop()
                            } else {
                                withAnimation {
                                    selectedWallpaper = wallpaper
                                }
                                try await wallpaperService.start(wallpaper)
                            }
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: selectedWallpaper)
                    .environmentObject(wallpaperService)
                }
            }
            .padding()
            
            Spacer()
            
            Group {
                if selectedWallpaper != nil {
                    Divider()
                    
                    OptionsView(selectedWallpaper: $selectedWallpaper)
                        .environmentObject(wallpaperService)
                } else {
                    Text("Select a wallpaper type")
                        .font(.title3.bold())
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
            .transition(.opacity)
            
            footer
        }
        .onReceive(popoverNotification) { _ in
            selectedWallpaper = wallpaperService.selectedWallpaper
        }
    }
    
    var footer: some View {
        HStack {
            Button {
                if #available(macOS 13.0, *) {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                } else {
                    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                }
                
                NSApp.activate(ignoringOtherApps: true)
            } label: {
                Image(systemName: "gearshape.fill")
            }
            .buttonStyle(.borderless)
            Spacer()

            if #available(macOS 13.0, *) {
                Menu {
                    footerButtons
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .buttonStyle(.borderless)
            } else {
                HStack {
                    footerButtons
                }
            }
        }
        .padding()
        .overlay(Divider(), alignment: .top)
    }

    var footerButtons: some View {
        Group {
            Button(action: openAbout) {
                Label("About", systemImage: "info")
            }

            if #available(macOS 13.0, *) {
                Divider()
            }

            Button {
                NSApplication.shared.terminate(self)
            } label: {
                Label("Quit", systemImage: "xmark")
            }
        }
    }
    
    struct WallpaperItem: View {
        @EnvironmentObject var wallpaperService: WallpaperService
        let wallpaper: WallpaperType
        
        typealias Action = (String, () -> Void)
        
        @Binding var selectedWallpaper: WallpaperType?
        var actions: [Action] = []
        let updateWallpaper: () -> Void
        
        @State private var isHolding: Bool = false
        @State private var isHovering: Bool = false
        
        var body: some View {
            VStack {
                Image(wallpaper.rawValue.capitalized + "Thumbnail")
                    .resizable()
                    .aspectRatio(16/10, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        selectedWallpaper == wallpaper ? RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.accentColor, lineWidth: 4) : nil
                    )
                    .overlay(
                        selectedWallpaper == wallpaper && wallpaperService.isLoading ? ProgressView() : nil
                    )
                    .overlay(
                        isHovering ? ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.black)
                                .opacity(0.5)
                            VStack {
                                Button(selectedWallpaper == wallpaper ? "Stop" : "Start") {
                                    guard !wallpaperService.isLoading else { return }
                                    updateWallpaper()
                                }
                                
                                ForEach(actions, id: \.0) { action in
                                    Button(action: action.1) {
                                        Text(action.0)
                                    }
                                }
                            }
                        } : nil
                    )
                    .shadow(radius: isHolding ? 4 : 8, y: isHolding ? 4 : 8)
                    .scaleEffect(isHolding ? 0.9 : 1)
                    .animation(.spring(), value: isHolding)
                    .onHover { isHovering in
                        withAnimation(.easeInOut) {
                            self.isHovering = isHovering
                        }
                    }
                    .onTapGesture {
                        isHolding = false
                        
                        guard !wallpaperService.isLoading else { return }
                        
                        updateWallpaper()
                    }
                    .onLongPressGesture { } onPressingChanged: { isHolding in
                        self.isHolding = isHolding
                    }
                
                Text(wallpaper.displayTitle)
                    .font(.headline)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView() {}
    }
}
#endif
