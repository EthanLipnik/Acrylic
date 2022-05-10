//
//  GenerateMeshGradientIntentHandler.swift
//  MeshGradientIntent
//
//  Created by Ethan Lipnik on 10/24/21.
//

import Foundation
import Intents
import UniformTypeIdentifiers
import UIKit
import RandomColor
import TelemetryClient

class GenerateMeshGradientIntentHandler: NSObject, GenerateMeshGradientIntentHandling {
    func resolveWidth(for intent: GenerateMeshGradientIntent) async -> GenerateMeshGradientWidthResolutionResult {
        if let width = intent.width {
            return .success(with: width.intValue)
        } else {
            return .needsValue()
        }
    }
    
    func resolveHeight(for intent: GenerateMeshGradientIntent) async -> GenerateMeshGradientHeightResolutionResult {
        if let height = intent.height {
            return .success(with: height.intValue)
        } else {
            return .needsValue()
        }
    }
    
    func resolveColorPalette(for intent: GenerateMeshGradientIntent) async -> ColorPaletteResolutionResult {
        if intent.colorPalette != .unknown {
            return .success(with: intent.colorPalette)
        } else {
            return .needsValue()
        }
    }
    
    func resolveLuminosity(for intent: GenerateMeshGradientIntent) async -> LuminosityResolutionResult {
        if intent.colorPalette != .unknown {
            return .success(with: intent.luminosity)
        } else {
            return .needsValue()
        }
    }
    
    func resolvePositionMultiplier(for intent: GenerateMeshGradientIntent) async -> GenerateMeshGradientPositionMultiplierResolutionResult {
        if let positionMultiplier = intent.positionMultiplier {
            return .success(with: positionMultiplier.doubleValue)
        } else {
            return .needsValue()
        }
    }
    
    func confirm(intent: GenerateMeshGradientIntent) async -> GenerateMeshGradientIntentResponse {
        return .init(code: .ready, userActivity: nil)
    }
    
    func handle(intent: GenerateMeshGradientIntent, completion: @escaping (GenerateMeshGradientIntentResponse) -> Void) {
        
#if SIRI
        DispatchQueue.global(qos: .background).async {
            let configuration = TelemetryManagerConfiguration(
                appID: "B278B666-F5F1-4014-882C-5403DA338EE5")
            TelemetryManager.initialize(with: configuration)
            
            TelemetryManager.send("meshGenerated")
        }
#endif
        
        DispatchQueue.global(qos: .background).async {
            var meshService: MeshService? = MeshService()
            meshService?.width = intent.width?.intValue ?? 3
            meshService?.height = intent.height?.intValue ?? 3
            meshService?.generate(Palette: .hue(from: intent.colorPalette),
                                  luminosity: .luminosity(from: intent.luminosity),
                                  positionMultiplier: intent.positionMultiplier?.floatValue ?? 0.5)
            
#if targetEnvironment(macCatalyst)
            let resolution = CGSize(width: 6144, height: 6144)
            meshService?.subdivsions = 64
#else
            let resolution = CGSize(width: 1280, height: 1280)
            meshService?.subdivsions = 16
#endif
            
            guard let render = meshService?.render(resolution: resolution) else { completion(.init(code: .failure, userActivity: nil)); return }
            
            meshService = nil
            
            DispatchQueue.main.async {
                let response = GenerateMeshGradientIntentResponse(code: .success, userActivity: nil)
                response.gradient = INFile(data: render.pngData()!, filename: "gradient.png", typeIdentifier: UTType.png.identifier)
                completion(response)
            }
            
            //            DispatchQueue.global(qos: .background).async {
            //                if intent.aspectRatio != .square {
            //                    let aspectRatio: CGFloat = {
            //                        switch intent.aspectRatio {
            //                        case .square:
            //                            return 1
            //                        case .a:
            //                            return 9/16
            //                        case .b:
            //                            return 16/9
            //                        case .c:
            //                            return 1/2
            //                        case .d:
            //                            return 2/1
            //                        case .e:
            //                            return 3/4
            //                        case .f:
            //                            return 4/3
            //                        default:
            //                            return 1
            //                        }
            //                    }()
            //                    if let ciImage = CIImage(image: render)?.resize(CGSize(width: resolution.width,
            //                                                                           height: resolution.height * aspectRatio)),
            //                       let data = CIContext().pngRepresentation(of: ciImage, format: .RG8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!) {
            //                        returnImage(image: data)
            //                    } else {
            //                        returnImage(image: render.pngData()!)
            //                    }
            //                } else {
            //                    returnImage(image: render.pngData()!)
            //                }
            //            }
        }
    }
}

extension RandomColor.Hue {
    static func hue(from palette: ColorPalette) -> RandomColor.Hue {
        switch palette {
        case .blue:
            return .blue
        case .orange:
            return .orange
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .pink:
            return .pink
        case .purple:
            return .purple
        case .red:
            return .red
        case .monochrome:
            return .monochrome
        case .rainbow:
            return .random
        case .random:
            return .randomPalette(includesMonochrome: true)
        default:
            return .monochrome
        }
    }
}

extension RandomColor.Luminosity {
    static func luminosity(from luminosity: Luminosity) -> RandomColor.Luminosity {
        switch luminosity {
        case .default:
            return .bright
        case .light:
            return .light
        case .dark:
            return .dark
        default:
            return .bright
        }
    }
}

extension ColorPalette {
    var allCases: [ColorPalette] {
        get {
            return [
                .monochrome,
                .blue,
                .green,
                .orange,
                .pink,
                .purple,
                .rainbow,
                .random
            ]
        }
    }
}

extension CIImage {
    func resize(_ size: CGSize) -> CIImage? {
        let resizeFilter = CIFilter(name:"CILanczosScaleTransform")
        
        let scale = size.height / self.extent.height
        let aspectRatio = size.width / (self.extent.width * scale)
        
        resizeFilter?.setValue(self, forKey: kCIInputImageKey)
        resizeFilter?.setValue(scale, forKey: kCIInputScaleKey)
        resizeFilter?.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        return resizeFilter?.outputImage
    }
}
