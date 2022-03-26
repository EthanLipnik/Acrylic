//
//  ExportService.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/25/22.
//

import Combine
import UIKit
import Blackbird

class ExportService: ObservableObject {
    @Published var blur: Float = 0 {
        didSet {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.applyFilters()
            }
        }
    }
    @Published var filteredImage: CIImage? = nil
    
    var renderImage: UIImage
    
    lazy var baseImage: CIImage = {
        return CIImage(image: renderImage)!
    }()
    
    init(renderImage: UIImage) {
        self.renderImage = renderImage
    }
    
    func applyFilters() {
        let image = baseImage
            .clampedToExtent()
            .applyingFilter(.gaussian, radius: NSNumber(value: blur))
        
        DispatchQueue.main.async { [weak self] in
            self?.self.filteredImage = image
        }
    }
}
