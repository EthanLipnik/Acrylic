//
//  SettingsView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/1/22.
//

#if !os(tvOS)
import SwiftUI
import RandomColor

struct SettingsView: View {
    struct HueToggle: Hashable {
        init(title: String, hue: Hue) {
            self.title = title
            self.hue = hue
            self.isOn = {
                let id = "isWallpaperPalette-\(title)Disabled"
                return !UserDefaults.standard.bool(forKey: id)
            }()
        }
        
        var title: String
        var hue: Hue
        var isOn: Bool {
            didSet {
                UserDefaults.standard.set(!isOn, forKey: "isWallpaperPalette-\(title)Disabled")
            }
        }
    }
    
    enum AnimationSpeed: String, Hashable, CaseIterable {
        case slow = "Slow"
        case normal = "Normal"
        case fast = "Fast"
    }
    
    enum PaletteChangeInterval: String, Hashable, CaseIterable {
        case fiveSec = "5 seconds"
        case thirtySec = "30 seconds"
        case oneMin = "1 minute"
        case fiveMin = "5 minutes"
        case twentyMin = "20 minutes"
        case thirtyMin = "30 minutes"
        case oneHour = "1 hour"
    }
    
    @State private var selectedHues: [HueToggle] = Hue.allCases.compactMap { hue in
        switch hue {
        case .blue:
            return HueToggle(title: "Blue", hue: .blue)
        case .orange:
            return HueToggle(title: "Orange", hue: .orange)
        case .yellow:
            return HueToggle(title: "Yellow", hue: .yellow)
        case .green:
            return HueToggle(title: "Green", hue: .green)
        case .pink:
            return HueToggle(title: "Pink", hue: .pink)
        case .purple:
            return HueToggle(title: "Purple", hue: .purple)
        case .red:
            return HueToggle(title: "Red", hue: .red)
        case .monochrome:
            return HueToggle(title: "Monochrome", hue: .monochrome)
        default:
            return nil
        }
    }
    
    @AppStorage("launchAtStartup") private var launchAtStartup: Bool = false
    @State private var isShowingPalettes: Bool = false
    @AppStorage("shouldStartWallpaperOnLaunch") private var startWallpaperOnLaunch: Bool = false
    @AppStorage("wallpaperSubdivisions") private var wallpaperSubdivisions: Int = 36
    @AppStorage("wallpaperAnimationSpeed") private var animationSpeed: AnimationSpeed = .normal
    @AppStorage("wallpaperPaletteChangeInterval") private var paletteChangeInterval: PaletteChangeInterval = .fiveMin

    var body: some View {
        Form {
#if os(macOS)
            Section {
                Toggle("Launch Acrylic on system startup", isOn: $launchAtStartup)
            } header: {
                Label {
                    Text("Startup")
                } icon: {
                    Image(systemName: "power.circle.fill")
                        .foregroundColor(.accentColor)
                }
            }
            
            dynamicWallpaperSettings
#endif
        }
        .groupedForm()
    }
    
    var dynamicWallpaperSettings: some View {
        Section {
            Toggle("Automatically start on launch", isOn: $startWallpaperOnLaunch)
            
            Picker(selection: $wallpaperSubdivisions) {
                Text("8")
                    .tag(8)
                Text("18")
                    .tag(16)
                Text("36")
                    .tag(36)
                Text("48")
                    .tag(48)
            } label: {
                Text("Subdivisions")
            }
            .pickerStyle(.menu)
            
            Picker(selection: $animationSpeed) {
                ForEach(AnimationSpeed.allCases, id: \.rawValue) {
                    Text($0.rawValue)
                        .tag($0)
                }
            } label: {
                Text("Animation Speed")
            }
            .pickerStyle(.menu)
            
            Section {
                Picker(selection: $paletteChangeInterval) {
                    ForEach(PaletteChangeInterval.allCases, id: \.rawValue) {
                        Text($0.rawValue)
                            .tag($0)
                    }
                } label: {
                    Text("Palette Change Interval")
                }
                .pickerStyle(.menu)
                
                if #available(iOS 16.0, macOS 13.0, *) {
                    DisclosureGroup(isExpanded: $isShowingPalettes) {
                        ForEach(selectedHues.indices, id: \.self) { index in
                            Toggle(selectedHues[index].title, isOn: $selectedHues[index].isOn)
                        }
                    } label: {
                        Toggle("All Palettes", isOn: $selectedHues.map(\.isOn))
                    }
                } else {
                    VStack {
                        ForEach(selectedHues.indices, id: \.self) { index in
                            Toggle(selectedHues[index].title, isOn: $selectedHues[index].isOn)
                        }
                    }
                }
            } header: {
                Text("Color Palette")
            }
        } header: {
            Label {
                VStack(alignment: .leading) {
                    Text("Dynamic Wallpaper")
                }
            } icon: {
                Image(systemName: "menubar.dock.rectangle")
                    .foregroundColor(.purple)
            }
        } footer: {
            Text("Dynamic Wallpaper gives you an animated wallpaper on your desktop. This can use moderate energy so it is recommended to not use on battery.")
                .font(.callout)
                .foregroundColor(.secondary)
        }
    }
}

struct MacSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

extension View {
    @ViewBuilder
    func groupedForm() -> some View {
        self.modifier(GroupedFormViewModifier())
    }
}

struct GroupedFormViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, macOS 13.0, *) {
            content.formStyle(.grouped)
        } else {
            content
        }
    }
}
#endif
