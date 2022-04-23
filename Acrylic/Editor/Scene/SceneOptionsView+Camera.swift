//
//  SceneOptionsView+Camera.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 4/22/22.
//

import SwiftUI

extension SceneOptionsView {
    struct CameraView: View {
        @EnvironmentObject var sceneService: SceneService
        
        var withBackground: Bool = true
        
        @State private var focusDistance: CGFloat = 0
        @State private var fStop: CGFloat = 0.1
        @State private var focalLength: CGFloat = 0
        
        @State private var filmGrainIntensity: Float = 0
        @State private var filmGrainScale: Float = 0
        
        var body: some View {
            OptionsView.DetailView(title: "Camera", systemImage: "camera.metering.center.weighted", withBackground: withBackground) {
                OptionsView.DetailView(title: "Depth of Field", systemImage: "line.3.crossed.swirl.circle.fill", withBackground: withBackground) {
                    HStack {
                        Image(systemName: "arrow.right.to.line.circle")
                            .foregroundColor(.secondary)
                        Slider(value: $focusDistance, in: 0.5...24)
                            .onAppear {
                                focusDistance = CGFloat(sceneService.sceneDocument.cameras.first?.depthOfFieldOptions.focusDistance ?? 12)
                            }
                            .onChange(of: focusDistance) { newValue in
                                sceneService.sceneDocument.cameras[0].depthOfFieldOptions.focusDistance = Float(newValue)
                                sceneService.sceneView?.pointOfView?.camera?.focusDistance = newValue
                            }
                    }
                    
                    HStack {
                        Image(systemName: "line.3.crossed.swirl.circle")
                            .foregroundColor(.secondary)
                        Slider(value: $fStop, in: 0.01...0.2)
                            .onAppear {
                                fStop = CGFloat(sceneService.sceneDocument.cameras.first?.depthOfFieldOptions.fStop ?? 0.1)
                            }
                            .onChange(of: fStop) { newValue in
                                sceneService.sceneDocument.cameras[0].depthOfFieldOptions.fStop = Float(newValue)
                                sceneService.sceneView?.pointOfView?.camera?.fStop = CGFloat(newValue)
                            }
                    }
                }
                
                OptionsView.DetailView(title: "Film Grain", systemImage: "circle.hexagongrid.circle") {
                    HStack {
                        Text("Intensity")
                            .bold()
                            .frame(width: 60, alignment: .leading)
                            .foregroundColor(.secondary)
                        Slider(value: $filmGrainIntensity, in: 0...2)
                            .onAppear {
                                filmGrainIntensity = sceneService.sceneDocument.cameras.first?.filmGrainOptions.intensity ?? 0
                            }
                            .onChange(of: filmGrainIntensity) { newValue in
                                sceneService.sceneDocument.cameras[0].filmGrainOptions.intensity = newValue
                                sceneService.sceneView?.pointOfView?.camera?.grainIntensity = CGFloat(newValue)
                            }
                    }
                    
                    HStack {
                        Text("Scale")
                            .bold()
                            .frame(width: 60, alignment: .leading)
                            .foregroundColor(.secondary)
                        Slider(value: $filmGrainScale, in: 0...2)
                            .onAppear {
                                filmGrainScale = sceneService.sceneDocument.cameras.first?.filmGrainOptions.scale ?? 1
                            }
                            .onChange(of: filmGrainScale) { newValue in
                                sceneService.sceneDocument.cameras[0].filmGrainOptions.scale = newValue
                                sceneService.sceneView?.pointOfView?.camera?.grainScale = CGFloat(newValue)
                            }
                    }
                }
            }
        }
    }
}
