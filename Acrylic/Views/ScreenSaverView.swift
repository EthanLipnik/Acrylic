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
    @EnvironmentObject var viewModel: FluidViewModel
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("FWPaletteChangeInterval") private var wallpaperPaletteChangeInterval: Double = 60
    @AppStorage("FWAnimationSpeed") private var animationSpeed: AnimationSpeed = .normal
    @AppStorage("FWSubdivisions") private var wallpaperSubdivisions: Int = 36
    @AppStorage("FWColorScheme") private var wallpaperColorScheme: WallpaperColorScheme = .system
    @AppStorage("FWGrainAlpha") private var wallpaperGrainAlpha: Double = Double(MeshDefaults.grainAlpha)
    @AppStorage("FWFramerate") private var fwFramerate: Int = 30
    
#if os(macOS)
    @State private var isStartingUp: Bool = true
#endif
    
    var animationSpeedRange: ClosedRange<Double> {
        switch animationSpeed {
        case .slow:
            return 8 ... 16
        case .normal:
            return 4 ... 8
        case .fast:
            return 1 ... 2
        }
    }
    
    var body: some View {
        ZStack {
            Mesh(
                colors: viewModel.colors,
                animatorConfiguration: .init(framesPerSecond: fwFramerate,
                                             animationSpeedRange: animationSpeedRange,
                                             meshRandomizer: viewModel.meshRandomizer),
                grainAlpha: Float(wallpaperGrainAlpha),
                subdivisions: wallpaperSubdivisions
            )
#if os(macOS)
            .transition(.opacity)
            .opacity(isStartingUp ? 0 : 1)
            .onAppear {
                withAnimation(.easeInOut(duration: 3)) {
                    isStartingUp = false
                }
            }
#endif
        }
        .ignoresSafeArea()
        .onChange(of: wallpaperPaletteChangeInterval) { newValue in
            viewModel.setTimer(newValue)
        }
        .onChange(of: colorScheme) { colorScheme in
            viewModel.newPalette()
        }
#if !os(tvOS)
        .overlay(
            Button("New Color") {
                viewModel.newPalette()
            }
                .keyboardShortcut(.space, modifiers: [])
                .hidden()
        )
#endif
    }
}

struct ScreenSaverView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenSaverView()
    }
}
