//
//  MeshService.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import Combine
import MeshKit
import UIKit

class MeshService: ObservableObject {
    @Published var colors: [MeshNode.Color] = []
    @Published var width: Int = 3
    @Published var height: Int = 3
    @Published var subdivsions: Int = 18
    @Published var contentScaleFactor: Float = 5
    @Published var isRenderingAsWireframe: Bool = false
    
    @Published var isExporting: Bool = false
    
    func render(completion: @escaping (UIImage) -> Void) {
        let view = MeshView(frame: CGRect(origin: .zero, size: CGSize(width: 512, height: 512)))
        view.create(colors, width: width, height: height, subdivisions: subdivsions)
        view.contentScaleFactor = CGFloat(contentScaleFactor)
        view.scaleFactor = CGFloat(contentScaleFactor)
        view.isHidden = true
        
        let scene = UIApplication.shared.connectedScenes.first
        if let sceneDelegate = scene?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController?.view.addSubview(view)
            view.frame = CGRect(origin: .zero, size: CGSize(width: 1024, height: 1024))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                completion(view.snapshot())
                view.removeFromSuperview()
            }
        }
    }
}
