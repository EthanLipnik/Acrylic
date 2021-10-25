//
//  GenerateMeshGradientIntentHandler.swift
//  MeshGradientIntent
//
//  Created by Ethan Lipnik on 10/24/21.
//

import Foundation
import Intents

class GenerateMeshGradientIntentHandler: NSObject, GenerateMeshGradientIntentHandling {
    
    func confirm(intent: GenerateMeshGradientIntent, completion: @escaping (GenerateMeshGradientIntentResponse) -> Void) {
        completion(.init(code: .ready, userActivity: nil))
    }
    
    func handle(intent: GenerateMeshGradientIntent, completion: @escaping (GenerateMeshGradientIntentResponse) -> Void) {
        let meshService = MeshService()
        meshService.render { image in
            let response = GenerateMeshGradientIntentResponse(code: .success, userActivity: nil)
            response.image = INFile(data: image.pngData()!, filename: "gradient", typeIdentifier: nil)
            completion(response)
        }
//        let photoInfoController = PhotoInfoController()
//        photoInfoController.fetchPhotoOfTheDay { (photoInfo) in
//            if let photoInfo = photoInfo {
//                completion(PhotoOfTheDayIntentResponse.success(photoTitle: photoInfo.title))
//            }
//        }
    }
}
