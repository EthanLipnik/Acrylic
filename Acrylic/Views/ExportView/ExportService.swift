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
import CoreImage
import SceneKit
import TelemetryClient

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
    
    @Published var previewImage: CIImage? = nil
    lazy var scaledImage: CIImage? = {
        return baseImage.resize(CGSize(width: 720, height: 720))
    }()
    
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
//    var scene: SCNScene
    
    lazy var baseImage: CIImage = {
        return CIImage(image: renderImage)!
    }()
    
    init(renderImage: UIImage/*, scene: SCNScene*/) {
        self.renderImage = renderImage
//        self.scene = scene
    }
    
    func applyFilters() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let baseImage = self.scaledImage ?? self.baseImage
            
            let image = baseImage
                .clampedToExtent()
                .applyingFilter(.gaussian, radius: NSNumber(value: self.blur))?
                .cropped(to: baseImage.extent)
            
            DispatchQueue.main.async {
                self.previewImage = image
            }
        }
    }
    
    func export() throws -> ImageDocument {
        let ciImage = baseImage
            .clampedToExtent()
            .applyingFilter(.gaussian, radius: NSNumber(value: self.blur))?
            .cropped(to: baseImage.extent)
            .resize(CGSize(width: self.resolution.width, height: self.resolution.height))?
            .cropped(to: CGRect(origin: baseImage.extent.origin, size: CGSize(width: self.resolution.width, height: self.resolution.height))) ?? baseImage
        
        guard let cgImage = Blackbird.shared.context.createCGImage(ciImage, from: ciImage.extent) else {
            TelemetryManager.send("renderFailed", with: ["error": "failed to create cgImage from ciImage."])
            throw CocoaError(.fileWriteUnknown)
        }
        let image = UIImage(cgImage: cgImage)
        
        var data: Data? = nil
        
        switch format {
        case .png:
            data = image.pngData()
        case .jpeg:
            data = image.jpegData(compressionQuality: compressionQuality)
        case .heic:
            data = try image.heicData(compressionQuality: compressionQuality)
        }
        
        if let data = data {
            TelemetryManager.send("renderExported", with: ["resolution": "\(resolution.width):\(resolution.height)"])
            return ImageDocument(imageData: data)
        } else {
            TelemetryManager.send("renderFailed", with: ["error": "failed to get image data from render."])
            throw CocoaError(.fileReadUnknown)
        }
    }
}

extension CIImage {
    func resize(_ size: CGSize) -> CIImage? {
        let scale = (Double)(size.width) / (Double)(self.extent.size.width)
        let filter = CIFilter(name: "CILanczosScaleTransform")!
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.setValue(NSNumber(value: scale), forKey: kCIInputScaleKey)
        filter.setValue(1.0, forKey:kCIInputAspectRatioKey)
        return filter.value(forKey: kCIOutputImageKey) as? CIImage
    }
}
