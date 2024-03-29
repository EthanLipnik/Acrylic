//
//  ScreenSaverView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 7/28/22.
//

import Combine
import MeshKit
import RandomColor
import SwiftUI

struct ScreenSaverView: View {
    @EnvironmentObject
    var viewModel: FluidViewModel
    @Environment(\.colorScheme)
    var colorScheme
    @AppStorage("FWPaletteChangeInterval")
    private var wallpaperPaletteChangeInterval: Double = 60
    @AppStorage("FWAnimationSpeed")
    private var animationSpeed: AnimationSpeed = .normal
    @AppStorage("FWSubdivisions")
    private var wallpaperSubdivisions: Int = 36
    @AppStorage("FWColorScheme")
    private var wallpaperColorScheme: WallpaperColorScheme = .system
    @AppStorage("FWGrainAlpha")
    private var wallpaperGrainAlpha: Double = .init(
        MeshDefaults
            .grainAlpha
    )
    @AppStorage("FWFramerate")
    private var fwFramerate: Int = 30
    @AppStorage("colorSpace")
    private var colorSpace: ColorSpace = .sRGB

    @State
    private var isStartingUp: Bool = true

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
                animatorConfiguration: .init(
                    framesPerSecond: fwFramerate,
                    animationSpeedRange: animationSpeedRange,
                    meshRandomizer: viewModel.meshRandomizer
                ),
                grainAlpha: Float(wallpaperGrainAlpha),
                subdivisions: wallpaperSubdivisions,
                colorSpace: colorSpace.cgColorSpace
            )
            .transition(.opacity)
            .opacity(isStartingUp ? 0 : 1)
            .onAppear {
                withAnimation(.easeInOut(duration: 3)) {
                    isStartingUp = false
                }
            }
        }
        .ignoresSafeArea()
        .onChange(of: wallpaperPaletteChangeInterval) { newValue in
            viewModel.setTimer(newValue)
        }
        .onChange(of: colorScheme) { _ in
            viewModel.newPalette()
        }
        .overlay(
            Button("New Color") {
                viewModel.newPalette()
            }
            .keyboardShortcut(.space, modifiers: [])
            .hidden()
        )
    }
}

struct ScreenSaverView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenSaverView()
    }
}
