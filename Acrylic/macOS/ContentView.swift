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
    @StateObject var wallpaperService = WallpaperService.shared
    
    var body: some View {
        ScrollView {
            Text("Acrylic")
                .font(.title.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.top, .horizontal])
            Divider()
            LazyVGrid(columns: [.init(.adaptive(minimum: 100))]) {
                ForEach(WallpaperType.allCases, id: \.rawValue) { wallpaper in
                    WallpaperItem(wallpaper: wallpaper, selectedWallpaper: $selectedWallpaper)
                        .animation(.easeInOut(duration: 0.2), value: selectedWallpaper)
                }
            }
            .padding([.horizontal, .bottom])
        }
        .onChange(of: selectedWallpaper) { wallpaper in
            Task(priority: .userInitiated) {
                do {
                    if let wallpaper {
                        try await wallpaperService.enable(wallpaper)
                    } else {
                        try await wallpaperService.disable()
                    }
                } catch {
                    print(error)
                }
            }
        }
        .overlay(
            HStack {
                Button {
                    if #available(macOS 13.0, *) {
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    } else {
                        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                    }
                } label: {
                    Image(systemName: "gearshape.fill")
                }
                .buttonStyle(.borderless)
                Spacer()
                
                Menu {
                    Button(action: openAbout) {
                        Label("About", systemImage: "info")
                    }
                    Divider()
                    Button {
                        NSApplication.shared.terminate(self)
                    } label: {
                        Label("Quit", systemImage: "xmark")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .buttonStyle(.borderless)
            }
                .padding()
                .overlay(Divider(), alignment: .top),
            alignment: .bottom
        )
    }
    
    struct WallpaperItem: View {
        let wallpaper: WallpaperType
        
        @Binding var selectedWallpaper: WallpaperType?
        @State private var isHolding: Bool = false
        
        var body: some View {
            Image(wallpaper.rawValue.capitalized + "Thumbnail")
                .resizable()
                .aspectRatio(16/9, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    selectedWallpaper == wallpaper ? RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.accentColor, lineWidth: 4) : nil
                )
                .shadow(radius: isHolding ? 4 : 8, y: isHolding ? 4 : 8)
                .scaleEffect(isHolding ? 0.9 : 1)
                .animation(.spring(), value: isHolding)
                .onTapGesture {
                    isHolding = false
                    
                    if selectedWallpaper == wallpaper {
                        selectedWallpaper = nil
                        return
                    }
                    selectedWallpaper = wallpaper
                }
                .onLongPressGesture { } onPressingChanged: { isHolding in
                    self.isHolding = isHolding
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
