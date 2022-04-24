//
//  SceneDocument+Presets.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 4/20/22.
//

import UIKit
import RandomColor

extension SceneDocument {
    
    func setPreset(_ preset: Preset?, hue: RandomColor.Hue? = nil) {
        self.preset = preset
        guard let preset = preset else {
            return
        }
        
        self.colorHue = .init(hue: hue ?? .randomPalette(includesMonochrome: true))
        guard let colorHue = colorHue else { return }
        
        func setupSettings() {
            antialiasing = .multisampling2X
            screenSpaceReflectionsOptions = .init(isEnabled: true, sampleCount: 64, maxDistance: 128)
            backgroundColor = .init(uiColor: randomColor(hue: colorHue.randomColorHue, luminosity: .light))
        }
        
        func setupLights() {
            let directionalLight = SceneDocument.Light(lightType: .directional,
                                                       castsShadow: true,
                                                       eulerAngles: SceneDocument.Vector3(x: 0, y: 45, z: 45))
            
            let ambientLight = SceneDocument.Light(lightType: .ambient,
                                                   color: SceneDocument.Color.init(uiColor: UIColor(hue: 0, saturation: 0, brightness: 0.7, alpha: 1)),
                                                   castsShadow: false)
            
            lights = [directionalLight, ambientLight]
        }
        
        func setupCameras() {
            let camera = SceneDocument.Camera(position: SceneDocument.Vector3(x: 0, y: 0, z: 12),
                                              screenSpaceAmbientOcclusionOptions: .init(isEnabled: true, intensity: 1.8),
                                              depthOfFieldOptions: .init(isEnabled: true, focusDistance: 12, fStop: 0.1, focalLength: 16),
                                              bloomOptions: .init(isEnabled: true, intensity: 0.2),
                                              filmGrainOptions: .init(isEnabled: true, scale: 1, intensity: 0.2),
                                              colorFringeOptions: .init(isEnabled: true, strength: 0.5, intensity: 0.5),
                                              useHDR: true,
                                              useAutoExposure: true)
            cameras = [camera]
        }
        
        switch preset {
        case .cluster(let shape, let positionMultiplier, let objectCount):
            let colors = randomColors(count: 1500, hue: colorHue.randomColorHue, luminosity: colorHue.randomColorLuminosity)
            var objects: [SceneDocument.Object] = []
            let roughness = self.objects.first?.material.roughness ?? 0.6
            for _ in 0..<objectCount {
                let randomScale = Float.random(in: 0.5..<1)
                let sphere = SceneDocument.Object(shape: shape,
                                                  material: .init(color: .init(uiColor: colors.randomElement() ?? .magenta), roughness: roughness),
                                                  position: .init(x: Float.random(in: -positionMultiplier..<positionMultiplier),
                                                                  y: Float.random(in: -positionMultiplier..<positionMultiplier),
                                                                  z: Float.random(in: -positionMultiplier..<positionMultiplier)),
                                                  scale: .init(x: randomScale, y: randomScale, z: randomScale))
                objects.append(sphere)
            }
            
            self.objects = objects
        case .wall(let shape, let positionMultiplier, let objectCount):
            break
        }
        
        setupSettings()
        setupLights()
        setupCameras()
    }
}
