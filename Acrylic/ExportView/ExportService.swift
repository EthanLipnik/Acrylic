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
    @Published var resolution: (width: Float, height: Float) = (4096, 4096)
    @Published var format: Format = .png
    @Published var compressionQuality: Float = 1
    
    @Published var filteredImage: CIImage? = nil
    
    enum Format: String, Hashable {
        case png = "PNG"
        case jpeg = "JPEG"
        case heif = "HEIF"
        
        var hasCompression: Bool {
            switch self {
            case .png:
                return false
            case .jpeg, .heif:
                return true
            }
        }
        
        static let allCases: [Self] = {
            return [
                .png,
                .jpeg,
                .heif
            ]
        }()
    }
    
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
            self?.filteredImage = image
        }
    }
    
    @objc func export() {
        let ciImage = filteredImage ?? baseImage
        let cgImage = Blackbird.shared.context.createCGImage(ciImage, from: baseImage.extent)!
        let image = UIImage(cgImage: cgImage)
        
        let data = image.pngData()!
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Mesh.png")
        try! data.write(to: url)
        
//#if targetEnvironment(macCatalyst)
//        let documentExporter = UIDocumentPickerViewController(forExporting: [url])
//        documentExporter.delegate = self
//        self.present(documentExporter, animated: true)
//#else
//        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
//        activityController.popoverPresentationController?.sourceRect = exportButton.bounds
//        activityController.popoverPresentationController?.sourceView = exportButton
//        self.present(activityController, animated: true)
//#endif
    }
}
