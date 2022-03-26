//
//  OptionsView+Colors.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/24/21.
//

import SwiftUI
import MeshKit
import UniformTypeIdentifiers
import RandomColor

extension OptionsView {
    struct SelectionView: View {
        @EnvironmentObject var meshService: MeshService
        
        var withBackground: Bool = true
        let clearColorsAction: () -> Void
        
        
        var body: some View {
            DetailView(title: "Selection", systemImage: "circle", withBackground: withBackground) {
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
                        if #available(iOS 15.0, macOS 15.0, *) {
                            Menu("New Palette") {
                                GeneratePaletteButton(title: "Blue", hue: .blue)
                                GeneratePaletteButton(title: "Green", hue: .green)
                                GeneratePaletteButton(title: "Red", hue: .red)
                                GeneratePaletteButton(title: "Orange", hue: .orange)
                                GeneratePaletteButton(title: "Pink", hue: .pink)
                                GeneratePaletteButton(title: "Purple", hue: .purple)
                                GeneratePaletteButton(title: "Monochrome", hue: .monochrome)
                                GeneratePaletteButton(title: "Rainbow", hue: .random)
                                GeneratePaletteButton(title: "Random", hue: .randomPalette())
                            } primaryAction: {
                                meshService.generate(pallete: .random)
                            }
                        } else {
                            Button("Randomize") {
                                meshService.generate(pallete: .random)
                            }
                        }
                        
                        Button("Randomize") {
                            meshService.randomizePositions()
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
                    meshService.generate(pallete: hue, shouldRandomizePointLocations: false)
                }.keyboardShortcut(.defaultAction)
                
                Button("Light") {
                    meshService.generate(pallete: hue, luminosity: .light, shouldRandomizePointLocations: false)
                }
                
                Button("Dark") {
                    meshService.generate(pallete: hue, luminosity: .dark, shouldRandomizePointLocations: false)
                }
                
                Button("Random") {
                    meshService.generate(pallete: hue, luminosity: .random, shouldRandomizePointLocations: false)
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
                        DetailView(title: "Tangent", systemImage: "point.topleft.down.curvedto.point.bottomright.up") {
                            Slider(value: uTangent, in: 0.0...5.0) {
                                Label("uTangent", systemImage: "trapezoid.and.line.horizontal.fill")
                            }
                            Slider(value: vTangent, in: 0.0...5.0) {
                                Label("vTangent", systemImage: "trapezoid.and.line.vertical.fill")
                            }
                        }
                    }
                } else {
                    EmptyView()
                }
            }
        }
    }
}
