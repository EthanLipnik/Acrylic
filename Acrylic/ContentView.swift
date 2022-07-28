//
//  ContentView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 7/28/22.
//

import SwiftUI
import MeshKit

#if !os(tvOS)
struct ContentView: View {
    @State private var meshRandomizer: MeshRandomizer
    @State private var colors: MeshGrid
    @State private var shouldAnimate: Bool = true
    @State private var grainAlpha: Float = MeshDefaults.grainAlpha
    @State private var subdivisions: Float = Float(MeshDefaults.subdivisions)

    init() {
        let colors = MeshKit.generate(palette: .blue, .red, .purple)
        _colors = .init(initialValue: colors)
        meshRandomizer = .withMeshColors(colors)
    }

    var body: some View {
        Group {
            if shouldAnimate {
                Mesh(colors: colors,
                     animatorConfiguration: .init(meshRandomizer: meshRandomizer),
                     grainAlpha: grainAlpha,
                     subdivisions: Int(subdivisions))
            } else {
                Mesh(colors: colors,
                     grainAlpha: grainAlpha,
                     subdivisions: Int(subdivisions))
            }
        }
        .toolbar {
            ToolbarItem(id: "randomize", placement: .navigation, showsByDefault: true) {
                Button {
                    colors = MeshKit.generate(palette: .random)
                    meshRandomizer = .withMeshColors(colors)
                } label: {
                    Label("Randomize", systemImage: "arrow.triangle.2.circlepath")
                }
                .keyboardShortcut("r")
            }

            ToolbarItem(id: "animate") {
                Toggle(isOn: $shouldAnimate) {
                    Label("Animate", systemImage: "arrow.up.and.down.and.arrow.left.and.right")
                }
            }

            ToolbarItem(id: "save", placement: .primaryAction, showsByDefault: true) {
                Button {

                } label: {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            OverlayView(grainAlpha: $grainAlpha, subdivisions: $subdivisions)
                .padding()
        }
        .ignoresSafeArea()
#if os(iOS)
        .statusBarHidden()
#endif
    }

    struct OverlayView: View {
        @Binding var grainAlpha: Float
        @Binding var subdivisions: Float

        var body: some View {
            VStack {
                GroupBox("Details") {
                    Slider(value: $grainAlpha, in: 0...0.25) {
                        Label("Grain", systemImage: "circle.grid.3x3.fill")
                    }
                    Slider(value: $subdivisions, in: 2...32, step: 1.0) {
                        Label("Subdivisions", systemImage: "cube.fill")
                    }
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Material.regular)
                    .shadow(radius: 16, y: 8)
            }
            .frame(maxWidth: 400)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
