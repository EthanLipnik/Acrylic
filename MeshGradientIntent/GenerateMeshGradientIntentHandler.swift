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
    
    func confirm(intent: GenerateMeshGradientIntent, completion: @escaping (GenerateMeshGradientIntentResponse) -> Void) {
        completion(.init(code: .ready, userActivity: nil))
    }
    
    func handle(intent: GenerateMeshGradientIntent, completion: @escaping (GenerateMeshGradientIntentResponse) -> Void) {
        let meshService = MeshService()
        meshService.colors = [
            .init(point: (0, 0), location: (0, 0), color: UIColor(red: 0.149, green: 0.275, blue: 0.325, alpha: 1.000)),
            .init(point: (0, 1), location: (0, 1), color: UIColor(red: 0.157, green: 0.447, blue: 0.443, alpha: 1.000)),
            .init(point: (0, 2), location: (0, 2), color: UIColor(red: 0.165, green: 0.616, blue: 0.561, alpha: 1.000)),
            
            .init(point: (1, 0), location: (1, 0), color: UIColor(red: 0.541, green: 0.694, blue: 0.490, alpha: 1.000)),
            .init(point: (1, 1), location: (Float.random(in: 0.2..<1.8), Float.random(in: 0.2..<1.8)), color: UIColor(red: 0.541, green: 0.694, blue: 0.490, alpha: 1.000)),
            .init(point: (1, 2), location: (1, 2), color: UIColor(red: 0.914, green: 0.769, blue: 0.416, alpha: 1.000)),
            
            .init(point: (2, 0), location: (2, 0), color: UIColor(red: 0.957, green: 0.635, blue: 0.380, alpha: 1.000)),
            .init(point: (2, 1), location: (2, 1), color: UIColor(red: 0.933, green: 0.537, blue: 0.349, alpha: 1.000)),
            .init(point: (2, 2), location: (2, 2), color: UIColor(red: 0.906, green: 0.435, blue: 0.318, alpha: 1.000)),
        ]
        
//        for i in 0..<meshService.colors.count {
//            meshService.colors[i].color = UIColor(hue: CGFloat(drand48()), saturation: 0.8, brightness: 1, alpha: 1)
//        }
        
        meshService.render { image in
            let response = GenerateMeshGradientIntentResponse(code: .success, userActivity: nil)
            response.image = INFile(data: image.pngData()!, filename: "gradient.png", typeIdentifier: UTType.png.identifier)
            completion(response)
        }
    }
}
