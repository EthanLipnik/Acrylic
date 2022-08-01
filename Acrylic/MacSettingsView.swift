//
//  SettingsView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/1/22.
//

import SwiftUI

#if os(macOS)
struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralView()
            WallpaperView()
        }
    }
    
    struct GeneralView: View {
        var body: some View {
            Form {
                SettingsView.SectionView("Startup") {
                    Toggle("Launch Acrylic on system startup", isOn: .constant(false))
                }
            }
            .tabItem {
                Label("General", systemImage: "gearshape")
            }
        }
    }
    
    struct WallpaperView: View {
        var body: some View {
            Text("Wallpaper")
                .tabItem {
                    Label("Wallpaper", systemImage: "menubar.dock.rectangle")
                }
        }
    }
    
    static func SectionView<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        return HStack(alignment: .top) {
            Text(title + ":")
            VStack {
                content()
            }
        }
    }
}

struct MacSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
