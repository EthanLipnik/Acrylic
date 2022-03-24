//
//  MeshService.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import Combine
import MeshKit
import UIKit
import RandomColor

class MeshService: ObservableObject {
    @Published var colors: [MeshNode.Color] = []
    @Published var width: Int = 3
    @Published var height: Int = 3
    @Published var subdivsions: Int = 18
    @Published var isRenderingAsWireframe: Bool = false
    
    @Published var selectedPoint: Point? = nil
    @Published var isExporting: Bool = false
    
    struct Point: Equatable {
        var x: Int
        var y: Int
        
        var nodePoint: (x: Int, y: Int) {
            return (x, y)
        }
    }
    
    func render(resolution: CGSize = CGSize(width: 1024, height: 1024)) -> UIImage {
        let scene = MeshScene()
        scene.create(colors, width: width, height: height, subdivisions: subdivsions)
        
        return scene.generate(size: resolution)
    }
    
    enum RandomizeMode {
        case framework
        case spectrum
    }
    
    func randomizePointsAndColors(_ mode: RandomizeMode = .framework) {
        var colors: [MeshNode.Color] = []
        
        let newColors: [UIColor] = {
            switch mode {
            case .framework:
                let hues: [Hue] = [
                    .blue,
                    .orange,
                    .yellow,
                    .green,
                    .pink,
                    .purple,
                    .red
                ]
                return randomColors(count: width * height, hue: hues.randomElement() ?? .blue, luminosity: .bright)
            case .spectrum:
                let initialColor = CGFloat.random(in: 0.1..<1)
                let initialSaturation = CGFloat.random(in: 0.6..<1)
                let initialBrightness = CGFloat.random(in: 0.8..<1)
                
                var colors: [UIColor] = []
                for _ in 0..<(width * height) {
                    colors.append(UIColor(hue: CGFloat.random(in: (initialColor - 0.15)..<(initialColor + 0.15)), saturation: initialSaturation, brightness: initialBrightness, alpha: 1))
                }
                
                return colors
            }
        }()
        
        for x in 0..<width {
            for y in 0..<height {
                autoreleasepool {
                    var location = (Float(x), Float(y))
                    
                    if x != 0 && x != width - 1 && y != 0 && y != height - 1 {
                        location = (Float.random(in: (Float(x) - 0.6)..<(Float(x) + 0.6)), Float.random(in: (Float(y) - 0.6)..<(Float(y) + 0.6)))
                    }
                    colors.append(.init(point: (x, y), location: location, color: newColors[(x * width) + y], tangent: (2, 2)))
                }
            }
        }
        
        self.colors = colors
    }
}
