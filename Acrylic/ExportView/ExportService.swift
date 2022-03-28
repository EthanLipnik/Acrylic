//
//  ExportService.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/25/22.
//

import Combine
import UIKit
import Blackbird
import UniformTypeIdentifiers

class ExportService: ObservableObject {
    @Published var blur: Float = 0 {
        didSet {
            applyFilters()
        }
    }
    @Published var resolution: (width: CGFloat, height: CGFloat) = (4096, 4096) {
        didSet {
            applyFilters()
        }
    }
    @Published var format: Format = .png
    @Published var compressionQuality: CGFloat = 1
    
    @Published var filteredImage: CIImage? = nil
    
    enum Format: String, Hashable {
        case png = "PNG"
        case jpeg = "JPEG"
        case heic = "HEIC"
        
        var hasCompression: Bool {
            switch self {
            case .png:
                return false
            case .jpeg, .heic:
                return true
            }
        }
        
        var fileExtension: String {
            switch self {
            case .png:
                return "png"
            case .jpeg:
                return "jpg"
            case .heic:
                return "heic"
            }
        }
        
        var type: UTType {
            switch self {
            case .png:
                return .png
            case .jpeg:
                return .jpeg
            case .heic:
                return .heic
            }
        }
        
        static let allCases: [Self] = {
            return [
                .png,
                .jpeg,
                .heic
            ]
        }()
    }
    
    var renderImage: UIImage
    
    lazy var baseImage: CIImage = {
        return CIImage(image: renderImage)!
    }()
    
    init(renderImage: UIImage, meshService: MeshService) {
        self.renderImage = renderImage
    }
    
    func applyFilters() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let image = self.baseImage
                .clampedToExtent()
                .applyingFilter(.gaussian, radius: NSNumber(value: self.blur))?
                .cropped(to: self.baseImage.extent)
            
            DispatchQueue.main.async {
                self.filteredImage = image
            }
        }
    }
    
    func export() -> Result<ImageDocument, Error> {
        let ciImage = filteredImage ?? baseImage
        let cgImage = Blackbird.shared.context.createCGImage(ciImage, from: baseImage.extent)!
        let image = UIImage(cgImage: cgImage)
        
        var data: Data? = nil
        
        switch format {
        case .png:
            data = image.pngData()
        case .jpeg:
            data = image.jpegData(compressionQuality: compressionQuality)
        case .heic:
            do {
                data = try image.heicData(compressionQuality: compressionQuality)
            } catch {
                return .failure(error)
            }
        }
        
        if let data = data {
            return .success(ImageDocument(imageData: data))
        } else {
            return .failure(CocoaError(.fileReadUnknown))
        }
    }
}
