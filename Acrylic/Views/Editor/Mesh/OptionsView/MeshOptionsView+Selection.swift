//
//  MeshOptionsView+Colors.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/24/21.
//

import SwiftUI
import MeshKit
import UniformTypeIdentifiers
import RandomColor

extension MeshOptionsView {
    struct SelectionView: View {
        @EnvironmentObject var meshService: MeshService

        var withBackground: Bool = true
        let clearColorsAction: () -> Void

        var body: some View {
            OptionsView.DetailView(title: "Selection",
                                   systemImage: "circle",
                                   withBackground: withBackground) {
                VStack(spacing: 20) {
                    let value = Binding<MeshNode.Color?>(get: { () -> MeshNode.Color? in
                        if let selectedPoint = meshService.selectedPoint {
                            return meshService.colors.first(where: { $0.point == selectedPoint.nodePoint })
                        } else {
                            return nil
                        }
                    }) { (value) in
                        if let selectedPoint = meshService.selectedPoint, let index = meshService.colors.firstIndex(where: { $0.point == selectedPoint.nodePoint }), let value = value {
                            meshService.colors[index] = value
                        }
                    }

                    PointView(node: value)
                    HStack {
                        Button("Clear", action: clearColorsAction)
#if !targetEnvironment(macCatalyst)
                            .hoverEffect()
#endif
                        Spacer()

                        Menu {
                            GeneratePaletteButton(title: "Blue", hue: .blue)
                            GeneratePaletteButton(title: "Green", hue: .green)
                            GeneratePaletteButton(title: "Red", hue: .red)
                            GeneratePaletteButton(title: "Orange", hue: .orange)
                            GeneratePaletteButton(title: "Pink", hue: .pink)
                            GeneratePaletteButton(title: "Purple", hue: .purple)
                            GeneratePaletteButton(title: "Monochrome", hue: .monochrome)
                            GeneratePaletteButton(title: "Rainbow", hue: .random)
                            GeneratePaletteButton(title: "Random", hue: .randomPalette())
                        } label: {
                            Image(systemName: "paintpalette")
                        }
                        .menuStyle(.borderlessButton)
#if targetEnvironment(macCatalyst)
                        .foregroundColor(.secondary)
#endif

                        Button {
                            meshService.randomizePositions()
                        } label: {
                            Image(systemName: "circle.grid.cross")
                        }

                        Button {
                            meshService.generate(Palette: .randomPalette(), luminosity: .bright, shouldRandomizePointLocations: true)
                        } label: {
                            Image(systemName: "shuffle.circle")
                        }
                    }
                }
            }
            .contextMenu {
                Menu("Paste Colors") {
                    Button("RGB") {
                        guard let copiedColors = UIPasteboard.general.string, copiedColors.contains("rgb(") else { return }
                        let rgbList = copiedColors
                            .replacingOccurrences(of: ",", with: "")
                            .replacingOccurrences(of: "rgb(", with: "")
                            .replacingOccurrences(of: ")", with: "")
                            .split(separator: "\n")
                            .map({ $0
                            .components(separatedBy: .whitespaces)
                            .compactMap({ Int($0) })
                                .map({ CGFloat($0) / 255 }) })

                        for i in 0..<rgbList.count {
                            if meshService.colors.count > i {
                                let rgb = rgbList[i]
                                DispatchQueue.main.async {
                                    withAnimation {
                                        meshService.colors[i].color = UIColor(red: rgb[0], green: rgb[1], blue: rgb[2], alpha: 1)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        @ViewBuilder
        private func GeneratePaletteButton(title: String, hue: Hue) -> some View {
            Menu(title) {
                Button("Default") {
                    meshService.generate(Palette: hue, shouldRandomizePointLocations: false)
                }.keyboardShortcut(.defaultAction)

                Button("Light") {
                    meshService.generate(Palette: hue, luminosity: .light, shouldRandomizePointLocations: false)
                }

                Button("Dark") {
                    meshService.generate(Palette: hue, luminosity: .dark, shouldRandomizePointLocations: false)
                }

                Button("Random") {
                    meshService.generate(Palette: hue, luminosity: .random, shouldRandomizePointLocations: false)
                }
            }
        }
    }

    struct PointView: View {
        @Binding var node: MeshNode.Color?

        var body: some View {
            Group {
                if let node = node {
                    let color = Binding<SwiftUI.Color>(get: { () -> SwiftUI.Color in
                        return Color(node.color)
                    }) { (value) in
                        self.node?.color = UIColor(value)
                    }

                    let uTangent = Binding<Float>(get: { () -> Float in
                        return node.tangent.u
                    }) { (value) in
                        self.node?.tangent.u = value
                    }

                    let vTangent = Binding<Float>(get: { () -> Float in
                        return node.tangent.v
                    }) { (value) in
                        self.node?.tangent.v = value
                    }

                    let tangentView = OptionsView.DetailView(title: "Tangent",
                                                             systemImage: "point.topleft.down.curvedto.point.bottomright.up") {
                        Text("Adjust the shape of the point")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)

                        Slider(value: uTangent, in: 0.0...5.0) {
                            Label("uTangent", systemImage: "trapezoid.and.line.horizontal.fill")
                        }
                        Slider(value: vTangent, in: 0.0...5.0) {
                            Label("vTangent", systemImage: "trapezoid.and.line.vertical.fill")
                        }
                    }

                    VStack(spacing: 20) {
                        HStack {
                            Label("Point", systemImage: "circle.fill")
                            Text("\(node.point.x),\(node.point.y)")
                                .font(.headline.bold())
                                .foregroundColor(Color.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }

                        HStack {
                            Label("Location", systemImage: "arrow.up.and.down.and.arrow.left.and.right")
                            Text(String(format: "%.1f", node.location.x) + "," + String(format: "%.1f", node.location.y))
                                .font(.headline.bold())
                                .foregroundColor(Color.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        ColorPicker(selection: color, supportsOpacity: false) {
                            Label("Color", systemImage: "paintbrush.fill")
                        }

                        if UIDevice.current.userInterfaceIdiom == .mac {
                            tangentView
                        } else {
                            tangentView.view
                        }
                    }
                } else {
                    Text("Tap one of the circles on the mesh to adjust it. Drag it to move it around.")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}
