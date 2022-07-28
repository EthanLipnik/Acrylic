//
//  ScreenSaverView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 7/28/22.
//

import SwiftUI
import MeshKit

struct ScreenSaverView: View {
    @State private var meshRandomizer: MeshRandomizer
    @State private var colors: MeshGrid

    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    init() {
        let colors = MeshKit.generate(palette: .blue)
        _colors = .init(initialValue: colors)
        meshRandomizer = .withMeshColors(colors)
    }

    var body: some View {
        Mesh(colors: colors,
             animatorConfiguration: .init(animationSpeedRange: 2 ... 4,
                                          meshRandomizer: meshRandomizer),
             subdivisions: 36)
        .ignoresSafeArea()
        .onReceive(timer) { _ in
            colors = MeshKit.generate(palette: .randomPalette(includesMonochrome: true))
            meshRandomizer = .withMeshColors(colors)
        }
    }
}

struct ScreenSaverView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenSaverView()
    }
}
