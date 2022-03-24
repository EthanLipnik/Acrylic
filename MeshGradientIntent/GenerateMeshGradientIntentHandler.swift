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
    
    func confirm(intent: GenerateMeshGradientIntent) async -> GenerateMeshGradientIntentResponse {
        return .init(code: .ready, userActivity: nil)
    }
    
    func handle(intent: GenerateMeshGradientIntent, completion: @escaping (GenerateMeshGradientIntentResponse) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let meshService = MeshService()
            meshService.width = intent.width?.intValue ?? 3
            meshService.height = intent.height?.intValue ?? 3
            meshService.subdivsions = 36
            meshService.randomizePointsAndColors()

    #if targetEnvironment(macCatalyst)
            let resolution = CGSize(width: 6144, height: 6144)
    #else
            let resolution = CGSize(width: 1280, height: 1280)
    #endif
            
            let render = meshService.render(resolution: resolution)
            
            DispatchQueue.main.async {
                do {
                    let response = GenerateMeshGradientIntentResponse(code: .success, userActivity: nil)
                    response.image = INFile(data: render.pngData()!, filename: "gradient.png", typeIdentifier: UTType.png.identifier)
                    completion(response)
                } catch {
                    completion(.init(code: .failure, userActivity: nil))
                }
            }
        }
    }
}
