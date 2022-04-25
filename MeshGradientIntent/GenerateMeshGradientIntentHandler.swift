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
        DispatchQueue.global(qos: .userInitiated).async {
            let meshService = MeshService()
            meshService.width = intent.width?.intValue ?? 3
            meshService.height = intent.height?.intValue ?? 3
            meshService.generate(Palette: .hue(from: intent.colorPalette),
                                 luminosity: .luminosity(from: intent.luminosity),
                                 positionMultiplier: intent.positionMultiplier?.floatValue ?? 0.5)
            
#if targetEnvironment(macCatalyst)
            let resolution = CGSize(width: 6144, height: 6144)
            meshService.subdivsions = 64
#else
            let resolution = CGSize(width: 1280, height: 1280)
            meshService.subdivsions = 36
#endif
            
            let render = meshService.render(resolution: resolution)
            
            DispatchQueue.main.async {
                let response = GenerateMeshGradientIntentResponse(code: .success, userActivity: nil)
                response.gradient = INFile(data: render.pngData()!, filename: "gradient.png", typeIdentifier: UTType.png.identifier)
                completion(response)
            }
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
