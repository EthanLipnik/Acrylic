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
import LaunchAtLogin

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
    
    enum Framerate: Int, Hashable, CaseIterable {
        case low = 30
        case normal = 60
        case high = 120
        
        var displayTitle: String {
            switch self {
            case .low:
                return "30 FPS"
            case .normal:
                return "60 FPS"
            case .high:
                return "120 FPS"
            }
        }
    }
    
    @State private var selectedHues: [HueToggle] = Hue.allCases.map(HueToggle.init)
    @State private var isShowingPalettes: Bool = false
    @AppStorage("shouldStartFWOnLaunch") private var startWallpaperOnLaunch: Bool = false
    @AppStorage("FWSubdivisions") private var wallpaperSubdivisions: Int = 8
    @AppStorage("FWAnimationSpeed") private var animationSpeed: AnimationSpeed = .normal
    @AppStorage("FWPaletteChangeInterval") private var paletteChangeInterval: Double = PaletteChangeInterval.oneMin.rawValue
    @AppStorage("shouldColorMatchFWMenuBar") private var colorMatchingMenuBar: Bool = true
    @AppStorage("FWColorScheme") private var wallpaperColorScheme: WallpaperColorScheme = .system
    @AppStorage("FWGrainAlpha") private var wallpaperGrainAlpha: Double = Double(MeshDefaults.grainAlpha)
    @AppStorage("FWFramerate") private var fwFramerate: Int = 30

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
                LaunchAtLogin.Toggle {
                    Text("Launch Acrylic on system startup")
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
                Text("2")
                    .tag(2)
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
            
            Slider(value: $wallpaperGrainAlpha, in: 0.01...0.25) {
                Text("Grain")
            }
            
            Picker(selection: $animationSpeed) {
                ForEach(AnimationSpeed.allCases, id: \.rawValue) {
                    Text($0.rawValue)
                        .tag($0)
                }
            } label: {
                Text("Animation Speed")
            }
            .pickerStyle(.menu)
            
            Picker("Framerate", selection: $fwFramerate) {
                Text("30 FPS")
                    .tag(30)
                Text("60 FPS")
                    .tag(60)
                Text("120 FPS")
                    .tag(120)
                Text("240 FPS")
                    .tag(240)
            }
            .pickerStyle(.menu)
            
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
                    if #available(iOS 16.0, macOS 13.0, *) {
                        Text("Transition Interval")
                        Text("How often the palette changes")
                    } else {
                        VStack(alignment: .leading) {
                            Text("Transition Interval")
                            Text("How often the palette changes")
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .pickerStyle(.menu)
                
                if #available(iOS 16.0, macOS 13.0, *) {
                    DisclosureGroup(isExpanded: $isShowingPalettes) {
                        ForEach(selectedHues.indices, id: \.self) { index in
                            Toggle(selectedHues[index].hue.displayTitle, isOn: $selectedHues[index].isOn)
                        }
                    } label: {
                        Toggle("All Palettes", sources: $selectedHues, isOn: \.isOn)
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
