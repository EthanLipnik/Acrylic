//
//  SceneOptionsView+Preset.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 4/10/22.
//

import SwiftUI
import RandomColor

extension SceneOptionsView {
    struct PresetView: View {
        @EnvironmentObject var sceneService: SceneService
        
        var withBackground: Bool = true
        
        let presets = ["Spheres", "Pyamids", "Cubes"]
        @State var selectedPreset: String = "Spheres"
        
        var objectCountIntProxy: Binding<Double>{
            Binding<Double>(get: {
                //returns the score as a Double
                return Double(sceneService.sceneDocument.objects.count)
            }, set: {
                sceneService.updateObjectCount(Int($0))
            })
        }
        
        var body: some View {
            OptionsView.DetailView(title: "Options", systemImage: "filemenu.and.selection", withBackground: withBackground) {
                HStack {
                    Picker("", selection: $selectedPreset) {
                        ForEach(presets, id: \.self) { Text($0) }
                    }.labelsHidden()
                    
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
                        sceneService.sceneDocument.objects.forEach({ $0.position = .init(x: Float.random(in: -10..<10), y: Float.random(in: -10..<10), z: Float.random(in: -10..<10)) })
                        sceneService.setupSceneView()
                    } label: {
                        Image(systemName: "circle.grid.cross")
                    }
                    
                    Button {
                        let hue = Hue.randomPalette(includesMonochrome: true)
                        sceneService.sceneDocument.colorHue = .init(hue: hue)
                        let colors = randomColors(count: Int(objectCountIntProxy.wrappedValue), hue: hue, luminosity: .bright)
                        sceneService.sceneDocument.objects.forEach { object in
                            object.material.color = .init(uiColor: colors.randomElement() ?? .magenta)
                            object.position = .init(x: Float.random(in: -10..<10), y: Float.random(in: -10..<10), z: Float.random(in: -10..<10))
                        }
                        sceneService.sceneDocument.backgroundColor = .init(uiColor: randomColor(hue: hue, luminosity: .light))
                        
                        sceneService.setupSceneView()
                    } label: {
                        Image(systemName: "shuffle.circle")
                    }
                }
                
                OptionsView.DetailView(title: "Object Count", systemImage: "list.bullet.indent", withBackground: true) {
                    Slider(value: objectCountIntProxy, in: 1...2000) {
                        Text("\(objectCountIntProxy.wrappedValue)")
                    } minimumValueLabel: {
                        Text("1")
                    } maximumValueLabel: {
                        Text("2000")
                    }
                }
            }
        }
        
        private func GeneratePaletteButton(title: String, hue: Hue) -> some View {
            func setColors(_ luminosity: RandomColor.Luminosity) {
                sceneService.sceneDocument.colorHue = .init(hue: hue, luminosity: luminosity)
                let colors = randomColors(count: Int(objectCountIntProxy.wrappedValue), hue: hue, luminosity: luminosity)
                sceneService.sceneDocument.objects.forEach({ $0.material.color = .init(uiColor: colors.randomElement() ?? .magenta) })
                sceneService.sceneDocument.backgroundColor = .init(uiColor: randomColor(hue: hue, luminosity: .light))
                
                sceneService.setupSceneView()
            }
            
            return Menu(title) {
                Button("Default") {
                    setColors(.bright)
                }.keyboardShortcut(.defaultAction)
                
                Button("Light") {
                    setColors(.light)
                }
                
                Button("Dark") {
                    setColors(.dark)
                }
                
                Button("Random") {
                    setColors(.random)
                }
            }
        }
    }
}
