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
    
    private var cancellables: Set<AnyCancellable> = []
    
#if !SIRI && !WIDGET
    var meshDocument: MeshDocument? = nil
    let shouldSave: Bool
    
    init(_ document: MeshDocument? = nil, shouldSave: Bool = true) {
        self.meshDocument = document
        self.shouldSave = shouldSave
        
        if let document = document {
            self.colors = document.colors
            self.width = document.width
            self.height = document.height
            self.subdivsions = document.subdivisions
            
            if shouldSave {
                objectWillChange
                    .debounce(for: .seconds(1), scheduler: DispatchQueue.global(qos: .background))
                    .sink { [weak self] object in
                        guard let self = self else { return }
                        self.meshDocument?.colors = self.colors
                        self.meshDocument?.subdivisions = self.subdivsions
                        self.meshDocument?.width = self.width
                        self.meshDocument?.height = self.height
                        
                        self.saveDocument()
                    }
                    .store(in: &cancellables)
            }
        }
    }
    
    func saveDocument() {
        if let fileUrl = meshDocument?.fileURL {
            DispatchQueue.global(qos: .background).async { [weak self] in
                let previewImage = self?.render(resolution: CGSize(width: 512, height: 512))
                self?.meshDocument?.previewImage = previewImage?.jpegData(compressionQuality: 0.5)
                self?.meshDocument?.save(to: fileUrl, for: .forOverwriting)
                
                print("🟢 Saved mesh document")
            }
        }
    }
#endif
    
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
    
    func generate(Palette hues: RandomColor.Hue...,
                  luminosity: RandomColor.Luminosity = .bright,
                  shouldRandomizePointLocations: Bool = true,
                  positionMultiplier: Float = 0.5) {
        var colors = Self.generateColors(palette: hues,
                            luminosity: luminosity,
                            width: width,
                            height: height,
                            shouldRandomizePointLocations: shouldRandomizePointLocations,
                            positionMultiplier: positionMultiplier)
        
        if !shouldRandomizePointLocations {
            for i in 0..<self.colors.count {
                let oldColor = self.colors[i]
                colors[i].location = oldColor.location
            }
        }
        
        self.colors = colors
    }
    
    static func generateColors(palette hues: [RandomColor.Hue],
                               luminosity: RandomColor.Luminosity = .bright,
                               width: Int = 3,
                               height: Int = 3,
                               shouldRandomizePointLocations: Bool = true,
                               positionMultiplier: Float = 0.5) -> [MeshNode.Color] {
        var colors: [MeshNode.Color] = []
        
        let newColors: [UIColor] = hues.flatMap({ randomColors(count: Int(ceil(Float(width * height) / Float(hues.count))), hue: $0, luminosity: luminosity) })
        
        for x in 0..<width {
            for y in 0..<height {
                autoreleasepool {
                    var location = (Float(x), Float(y))
                    
                    if (x != 0 && x != width - 1 && y != 0 && y != height - 1) && shouldRandomizePointLocations && positionMultiplier != 0 {
                        location = (Float.random(in: (Float(x) - positionMultiplier)..<(Float(x) + positionMultiplier)), Float.random(in: (Float(y) - positionMultiplier)..<(Float(y) + positionMultiplier)))
                    }
                    
                    var colorIndex: Int = 0
                    let xColorIndex = (x * width) + y
                    let yColorIndex = (y * height) + x
                    
                    if xColorIndex < newColors.count {
                        colorIndex = xColorIndex
                    } else if yColorIndex < newColors.count {
                        colorIndex = yColorIndex
                    }
                    
                    colors.append(.init(point: (x, y), location: location, color: newColors[min(colorIndex, newColors.count - 1)], tangent: (2, 2)))
                }
            }
        }
        
        return colors
    }
    
    func randomizePositions(positionMultiplier: Float = 0.5) {
        for i in 0..<colors.count {
            let x = colors[i].point.x
            let y = colors[i].point.y
            
            if (x != 0 && x != width - 1 && y != 0 && y != height - 1) && positionMultiplier != 0 {
                colors[i].location = (Float.random(in: (Float(x) - positionMultiplier)..<(Float(x) + positionMultiplier)), Float.random(in: (Float(y) - positionMultiplier)..<(Float(y) + positionMultiplier)))
            }
        }
    }
}

extension Hue {
    static var allCases: [Hue] {
        get {
            return [
                .blue,
                .orange,
                .yellow,
                .green,
                .pink,
                .purple,
                .red,
                .monochrome
            ]
        }
    }
    
    static func randomPalette(includesMonochrome: Bool = false) -> Hue {
        var hues = allCases
        
        if includesMonochrome {
            hues.removeLast()
        }
        
        return hues.randomElement() ?? .monochrome
    }
}
