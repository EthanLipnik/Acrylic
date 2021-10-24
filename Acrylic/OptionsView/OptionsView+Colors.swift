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
        DetailView(title: "Colors", systemImage: "paintbrush") {
            VStack(spacing: 20) {
                LazyVGrid(columns: [.init(.adaptive(minimum: 75, maximum: 100), spacing: 10)], spacing: 10) {
                    ForEach($meshService.colors) { color in
                        ColorView(color: color)
                    }
                }
                .rotationEffect(.degrees(-90))
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
        
        @State private var isPresentingPopover: Bool = false
        
        var body: some View {
            Button {
                isPresentingPopover.toggle()
            } label: {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(color.color))
                    .aspectRatio(1/1, contentMode: .fit)
                    .shadow(color: Color(color.color).opacity(0.4), radius: 10, y: 4)
                    .rotationEffect(.degrees(90))
            }
            .buttonStyle(.plain)
#if !targetEnvironment(macCatalyst)
            .hoverEffect()
#endif
            .popover(isPresented: $isPresentingPopover) {
                ColorPickerView(color: color.color) { color in
                    self.color.color = color
                }
            }
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
