//
//  SettingsView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/1/22.
//

#if !os(tvOS)
import SwiftUI
import RandomColor
import MeshKit

#if canImport(ServiceManagement)
import ServiceManagement
#endif

struct SettingsView: View {
    struct HueToggle: Hashable {
        init(_ hue: Hue) {
            self.hue = hue
            self.isOn = {
                let id = "isWallpaperPalette-\(hue.displayTitle)Disabled"
                return !UserDefaults.standard.bool(forKey: id)
            }()
        }
        
        var hue: Hue
        var isOn: Bool {
            didSet {
                UserDefaults.standard.set(!isOn, forKey: "isWallpaperPalette-\(hue.displayTitle)Disabled")
            }
        }
    }
    
    enum PaletteChangeInterval: Double, Hashable, CaseIterable {
        case fiveSec = 5
        case thirtySec = 30
        case oneMin = 60
        case fiveMin = 300
        case twentyMin = 1200
        case thirtyMin = 1800
        case oneHour = 3600
        
        var displayTitle: String {
            switch self {
            case .fiveSec:
                return "5 seconds"
            case .thirtySec:
                return "30 seconds"
            case .oneMin:
                return "1 minute"
            case .fiveMin:
                return "5 minutes"
            case .twentyMin:
                return "20 minutes"
            case .thirtyMin:
                return "30 minutes"
            case .oneHour:
                return "1 hour"
            }
        }
    }
    
    @State private var selectedHues: [HueToggle] = Hue.allCases.map(HueToggle.init)
    
    @State private var isShowingPalettes: Bool = false
    @AppStorage("launchAtStartup") private var launchAtStartup: Bool = false
    @AppStorage("shouldStartWallpaperOnLaunch") private var startWallpaperOnLaunch: Bool = false
    @AppStorage("wallpaperSubdivisions") private var wallpaperSubdivisions: Int = 36
    @AppStorage("wallpaperAnimationSpeed") private var animationSpeed: AnimationSpeed = .normal
    @AppStorage("wallpaperPaletteChangeInterval") private var paletteChangeInterval: Double = PaletteChangeInterval.fiveMin.rawValue
    @AppStorage("shouldColorMatchWallpaperMenuBar") private var colorMatchingMenuBar: Bool = true
    @AppStorage("wallpaperColorScheme") private var wallpaperColorScheme: WallpaperColorScheme = .system
    @AppStorage("wallpaperGrainAlpha") private var wallpaperGrainAlpha: Double = Double(MeshDefaults.grainAlpha)

    var body: some View {
        Group {
            if #available(iOS 14.0, macOS 13.0, *) {
                Form {
                    content
                }.groupedForm()
            } else {
                ScrollView {
                    content
                }
            }
        }
    }

    var content: some View {
        Group {
#if os(macOS)
            SectionView {
                Toggle("Launch Acrylic on system startup", isOn: $launchAtStartup)
                    .onChange(of: launchAtStartup) { newValue in
                        SMLoginItemSetEnabled("com.ethanlipnik.Acrylic.LaunchApplication" as CFString, newValue)
                    }
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
    }
    
    var dynamicWallpaperSettings: some View {
        SectionView {
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
            
            Slider(value: $wallpaperGrainAlpha, in: 0.01...0.25) {
                Text("Grain")
            }
            
            SectionView {
                Toggle("Color Match Menu Bar", isOn: $colorMatchingMenuBar)
                
                Picker(selection: $wallpaperColorScheme) {
                    ForEach(WallpaperColorScheme.allCases, id: \.self) { colorScheme in
                        Text(colorScheme.rawValue.capitalized)
                            .tag(colorScheme)
                    }
                } label: {
                    Text("Color Scheme")
                }
                .pickerStyle(.menu)

                
                Picker(selection: $paletteChangeInterval) {
                    ForEach(PaletteChangeInterval.allCases, id: \.rawValue) {
                        Text($0.displayTitle)
                            .tag($0.rawValue)
                    }
                } label: {
                    VStack(alignment: .leading) {
                        Text("Transition Interval")
                        Text("How often the palette changes")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                }
                .pickerStyle(.menu)
                
                if #available(iOS 16.0, macOS 13.0, *) {
                    DisclosureGroup(isExpanded: $isShowingPalettes) {
                        ForEach(selectedHues.indices, id: \.self) { index in
                            Toggle(selectedHues[index].hue.displayTitle, isOn: $selectedHues[index].isOn)
                        }
                    } label: {
                        Toggle("All Palettes", isOn: $selectedHues.map(\.isOn))
                    }
                } else {
                    VStack(alignment: .leading) {
                        ForEach(selectedHues.indices, id: \.self) { index in
                            Toggle(selectedHues[index].hue.displayTitle, isOn: $selectedHues[index].isOn)
                        }
                    }
                }
            } header: {
                Text("Color Palette")
            }
        } header: {
            Label {
                VStack(alignment: .leading) {
                    Text("Fluid Wallpaper")
                }
            } icon: {
                Image(systemName: "menubar.dock.rectangle")
                    .foregroundColor(.purple)
            }
        } footer: {
            Text("Fluid Wallpaper gives you an animated wallpaper on your desktop. This can use moderate energy so it is recommended to not use on battery. This will override your current desktop picture.")
                .font(.callout)
                .foregroundColor(.secondary)
        }
    }

    struct SectionView<Content: View, Header: View>: View {
        let contentView: Content
        let headerView: Header
        let footerView: AnyView?

        init(@ViewBuilder content: () -> Content, @ViewBuilder header: () -> Header) {
            self.contentView = content()
            self.headerView = header()
            self.footerView = nil
        }

        init<Footer: View>(@ViewBuilder content: () -> Content, @ViewBuilder header: () -> Header, @ViewBuilder footer: () -> Footer) {
            self.contentView = content()
            self.headerView = header()
            self.footerView = AnyView(footer())
        }

        var body: some View {
            Group {
                if #available(iOS 16.0, macOS 13.0, *) {
                    if let footerView {
                        Section {
                            contentView
                        } header: {
                            headerView
                        } footer: {
                            footerView
                        }
                    } else {
                        Section {
                            contentView
                        } header: {
                            headerView
                        }

                    }
                } else {
                    GroupBox {
                        contentView
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if let footerView {
                            footerView
                        }
                    } label: {
                        headerView
                    }
                    .padding()
                }
            }
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
