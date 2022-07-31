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
    @State private var meshRandomizer: MeshRandomizer
    @State private var colors: MeshGrid
    
    var luminosity: Luminosity
    var gridDidChange: ((_ colors: MeshGrid) -> Void)?

    let timer: Publishers.Autoconnect<Timer.TimerPublisher>

    init(changeInterval: Double = 10, luminosity: Luminosity = .bright, gridDidChange: ((_ colors: MeshGrid) -> Void)? = nil) {
        let colors = MeshKit.generate(palette: .blue, luminosity: luminosity)
        _colors = .init(initialValue: colors)
        meshRandomizer = .withMeshColors(colors)
        
        self.luminosity = luminosity
        self.gridDidChange = gridDidChange
        gridDidChange?(colors)
        
        self.timer = Timer.publish(every: changeInterval, on: .main, in: .common).autoconnect()
    }

    var body: some View {
        Mesh(colors: colors,
             animatorConfiguration: .init(animationSpeedRange: 2 ... 4,
                                          meshRandomizer: meshRandomizer),
             subdivisions: 36)
        .ignoresSafeArea()
        .onReceive(timer) { _ in
            newPalette()
        }
#if !os(tvOS)
        .overlay {
            Button("New Color") {
                newPalette()
            }
            .keyboardShortcut(.space, modifiers: [])
            .hidden()
        }
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
        colors = MeshKit.generate(palette: .randomPalette(includesMonochrome: true), luminosity: luminosity)
        meshRandomizer = .withMeshColors(colors)
        
        gridDidChange?(colors)
    }
}

struct ScreenSaverView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenSaverView()
    }
}
