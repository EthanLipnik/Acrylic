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
    var colorsView: some View {
        let value = Binding<[MeshNode.Color]>(get: { () -> [MeshNode.Color] in
            return meshService.colors.sorted(by: { $0.point.y > $1.point.y })
        }) { (value) in
            meshService.colors = value
        }
        
        return DetailView(title: "Colors", systemImage: "paintbrush") {
            VStack(spacing: 20) {
                if !meshService.colors.isEmpty {
                    LazyVGrid(columns: [GridItem](repeating: GridItem(.flexible(minimum: 25, maximum: 75), spacing: 10), count: meshService.width), spacing: 10) {
                        ForEach(value) { color in
                            ColorView(color: color)
                        }
                    }
                }
                HStack {
                    Button("Clear", action: clearColors)
                    Spacer()
                    Button("Randomize", action: randomizeColors)
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
    
    struct ColorView: View {
        @Binding var color: MeshNode.Color
        
        var body: some View {
            let value = Binding<Color>(get: { () -> Color in
                return Color(color.color)
            }) { (value) in
                color.color = UIColor(value)
            }
            
            return ColorPicker("", selection: value, supportsOpacity: false)
                .aspectRatio(1/1, contentMode: .fit)
#if !targetEnvironment(macCatalyst)
                .hoverEffect()
                .labelsHidden()
#endif
                .onDrop(of: [UTType.data.identifier], isTargeted: nil) { providers, location in
                    guard let provider = providers.first else { return false }
                    if provider.hasItemConformingToTypeIdentifier("com.apple.uikit.color") {
                        provider.loadObject(ofClass: UIColor.self) { reading, error in
                            DispatchQueue.main.async {
                                color.color = reading as! UIColor
                            }
                        }
                    }
                    return true
                }
        }
    }
}
