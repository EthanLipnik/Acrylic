//
//  ScreenSaverView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 7/28/22.
//

import SwiftUI
import MeshKit
import Combine
import RandomColor

struct ScreenSaverView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var meshRandomizer: MeshRandomizer?
    @State private var colors: MeshGrid?
    @State private var timer = Timer.publish(every: 300, on: .main, in: .common).autoconnect()
    @AppStorage("wallpaperPaletteChangeInterval") private var wallpaperPaletteChangeInterval: Double = 300
    @AppStorage("wallpaperAnimationSpeed") private var animationSpeed: AnimationSpeed = .normal
    @AppStorage("wallpaperSubdivisions") private var wallpaperSubdivisions: Int = 36
    @AppStorage("wallpaperColorScheme") private var wallpaperColorScheme: WallpaperColorScheme = .system
    @AppStorage("wallpaperGrainAlpha") private var wallpaperGrainAlpha: Double = Double(MeshDefaults.grainAlpha)
    
    typealias GridCallback = ((_ colors: MeshGrid) -> Void)?
    
    var luminosity: Luminosity {
        get {
            switch wallpaperColorScheme {
            case .light:
                return .light
            case .dark:
                return .dark
            case .system:
                return colorScheme == .light ? .light : .dark
            case .vibrant:
                return .bright
            }
        }
    }
    var animationSpeedRange: ClosedRange<Double> {
        switch animationSpeed {
        case .slow:
            return 4 ... 8
        case .normal:
            return 2 ... 4
        case .fast:
            return 1 ... 2
        }
    }
    var allowedPalettes: [Hue] {
        return Hue.allCases.filter({ !UserDefaults.standard.bool(forKey: "isWallpaperPalette-\($0.displayTitle)Disabled") })
    }
    var gridDidChange: GridCallback

    init(gridDidChange: GridCallback = nil) {
        let colors = MeshKit.generate(palette: .monochrome, luminosity: .dark)
        _colors = .init(initialValue: colors)
        _meshRandomizer = .init(initialValue: .withMeshColors(colors))
        
        self.gridDidChange = gridDidChange
        gridDidChange?(colors)
    }

    var body: some View {
        Group {
            if let colors,
               let meshRandomizer {
                Mesh(colors: colors,
                     animatorConfiguration: .init(animationSpeedRange: animationSpeedRange,
                                                  meshRandomizer: meshRandomizer),
                     grainAlpha: Float(wallpaperGrainAlpha),
                     subdivisions: wallpaperSubdivisions)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            self.timer = Timer.publish(every: wallpaperPaletteChangeInterval, on: .main, in: .common).autoconnect()
            newPalette()
        }
        .onChange(of: wallpaperPaletteChangeInterval) { newValue in
            self.timer = Timer.publish(every: newValue, on: .main, in: .common).autoconnect()
        }
        .onChange(of: colorScheme) { _ in
            newPalette()
        }
        .onReceive(timer) { _ in
            newPalette()
        }
#if !os(tvOS)
        .overlay(
            Button("New Color") {
                newPalette()
            }
            .keyboardShortcut(.space, modifiers: [])
            .hidden()
        )
#endif
//#if os(macOS)
//        .onHover { isHovering in
//            if isHovering {
//                NSCursor.hide()
//            } else {
//                NSCursor.unhide()
//            }
//        }
//#endif
    }

    func newPalette() {
        colors = MeshKit.generate(palette: allowedPalettes.randomElement() ?? .monochrome, luminosity: luminosity)
        guard let colors else { return }
        meshRandomizer = .withMeshColors(colors)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (animationSpeedRange.lowerBound * 2)) {
            gridDidChange?(colors)
        }
    }
}

struct ScreenSaverView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenSaverView()
    }
}
