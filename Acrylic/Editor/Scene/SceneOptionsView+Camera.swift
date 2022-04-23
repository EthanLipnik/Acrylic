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
        
        var body: some View {
            OptionsView.DetailView(title: "Camera", systemImage: "camera.metering.center.weighted", withBackground: withBackground) {
                OptionsView.DetailView(title: "Depth of Field", systemImage: "line.3.crossed.swirl.circle.fill", withBackground: withBackground) {
                    Slider(value: $focusDistance, in: 0.5...24) {
                        Label("Focus Distance", image: "arrow.right.to.line")
                    }
                    .onAppear {
                        focusDistance = CGFloat(sceneService.sceneDocument.cameras.first?.depthOfFieldOptions.focusDistance ?? 12)
                    }
                    .onChange(of: focusDistance) { newValue in
                        sceneService.sceneDocument.cameras[0].depthOfFieldOptions.focusDistance = Float(newValue)
                        sceneService.camera.focusDistance = CGFloat(newValue)
                    }
                    
                    Slider(value: $fStop, in: 0.01...0.2) {
                        Label("fStop", image: "arrow.right.to.line")
                    }
                    .onAppear {
                        fStop = CGFloat(sceneService.sceneDocument.cameras.first?.depthOfFieldOptions.fStop ?? 0.1)
                    }
                    .onChange(of: fStop) { newValue in
                        sceneService.sceneDocument.cameras[0].depthOfFieldOptions.fStop = Float(newValue)
                        sceneService.camera.fStop = CGFloat(newValue)
                    }
                }
            }
        }
    }
}
