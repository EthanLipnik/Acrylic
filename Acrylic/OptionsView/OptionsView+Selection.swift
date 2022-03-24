//
//  OptionsView+Colors.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/24/21.
//

import SwiftUI
import MeshKit
import UniformTypeIdentifiers

extension OptionsView {
    struct SelectionView: View {
        @EnvironmentObject var meshService: MeshService
        
        var withBackground: Bool = true
        let clearColorsAction: () -> Void
        let randomizeColorsAction: () -> Void
        
        @State private var showRandomizeConfirmation: Bool = false
        
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
                        Button("Randomize", role: .destructive) {
                            showRandomizeConfirmation.toggle()
                        }
#if !targetEnvironment(macCatalyst)
                        .hoverEffect()
#endif
                        .confirmationDialog(Text("Are you sure you want to randomize points and colors?"), isPresented: $showRandomizeConfirmation, actions: {
                            Button("Cancel", role: .cancel) {
                                showRandomizeConfirmation = false
                            }
                            Button("Randomize", role: .destructive, action: randomizeColorsAction)
                        }, message: {
                            Text("This will replace your current work.")
                        })
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
    }
    
    struct PointView: View {
        @Binding var node: MeshNode.Color?
        
        var body: some View {
            Group {
                if let node = node {
                    let color = Binding<Color>(get: { () -> Color in
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
