//
//  ExportService.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/25/22.
//

import Combine
import UIKit.UIImage
import UniformTypeIdentifiers
import CoreImage
import TelemetryClient

class ExportService: ObservableObject {
    @Published var blur: Float = 0 {
        didSet {
            applyFilters()
        }
    }
    @Published var resolution: (width: CGFloat, height: CGFloat) = (1024, 1024) {
        didSet {
            reset()
        }
    }
    @Published var format: Format = .png
    @Published var compressionQuality: CGFloat = 1
    @Published var isProcessing: Bool = false
    
    @Published var subdivisions: Int = 18
    
    @Published var ambientOcclusionIntensity: Float = 0
    
    @Published var previewImage: CIImage? = nil
    var scaledImage: CIImage? = nil
    
    private var cancellables: Set<AnyCancellable> = []
    
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
    
    var document: Document
    var baseImage: CIImage? = nil
    
    init(document: Document) {
        self.document = document
        
        switch document {
        case .mesh(let meshDocument):
            self.subdivisions = meshDocument.subdivisions
        case .scene(let sceneDocument):
            self.ambientOcclusionIntensity = sceneDocument.cameras.first?.screenSpaceAmbientOcclusionOptions.intensity ?? 0
        }
        
        self.isProcessing = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let render = self?.render() else { return }
            self?.baseImage = CIImage(image: render)
            self?.scaledImage = self?.baseImage?.resize(CGSize(width: 512, height: 512))
            self?.applyFilters()
            
            DispatchQueue.main.async {
                self?.isProcessing = false
            }
        }
        
        $ambientOcclusionIntensity
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reset()
            }
            .store(in: &cancellables)
        
        $subdivisions
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reset()
            }
            .store(in: &cancellables)
    }
    
    func reset() {
        isProcessing = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.baseImage = CIImage(image: self.render()) ?? self.baseImage
            self.scaledImage = self.baseImage?.resize(CGSize(width: 512, height: 512))
            self.applyFilters()
            
            DispatchQueue.main.async {
                self.isProcessing = false
            }
        }
    }
    
    func applyFilters() {
        DispatchQueue.main.async { [weak self] in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let self = self,
                      let image = self.scaledImage ?? self.baseImage else { return }
                
                let filteredImage = image
                    .clampedToExtent()
                    .applyingFilter(.gaussian, radius: NSNumber(value: self.blur))?
                    .cropped(to: image.extent)
                
                DispatchQueue.main.async {
                    self.previewImage = filteredImage
                }
            }
        }
    }
    
    func export(completion: @escaping (Result<ImageDocument, Error>) -> Void) {
        DispatchQueue.main.async {  [weak self] in
            self?.isProcessing = true
            
            DispatchQueue.global(qos: .userInitiated).async {
                guard let self = self else { return }
                let render = self.render()
                let renderImage = CIImage(image: render) ?? .init()
                
                let context = CIContext(options: nil)
                
                guard let ciImage = renderImage
                    .clampedToExtent()
                    .applyingFilter(.gaussian, radius: NSNumber(value: self.blur))?
                    .cropped(to: renderImage.extent) ?? self.baseImage,
                      let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
                else {
                    TelemetryManager.send("renderFailed", with: ["error": "failed to create cgImage from ciImage."])
                    completion(.failure(CocoaError(.fileWriteUnknown)))
                    return
                }
                
                let image = UIImage(cgImage: cgImage)
                
                var data: Data? = nil
                
                switch self.format {
                case .png:
                    data = image.pngData()
                case .jpeg:
                    data = image.jpegData(compressionQuality: self.compressionQuality)
                case .heic:
                    do {
                        data = try image.heicData(compressionQuality: self.compressionQuality)
                    } catch {
                        completion(.failure(error))
                        return
                    }
                }
                
                if let data = data {
                    TelemetryManager.send("renderExported")
                    completion(.success(ImageDocument(imageData: data)))
                } else {
                    TelemetryManager.send("renderFailed", with: ["error": "failed to get image data from render."])
                    completion(.failure(CocoaError(.fileReadUnknown)))
                }
                
                DispatchQueue.main.async {
                    self.isProcessing = false
                }
            }
        }
    }
    
    func render() -> UIImage {
        switch document {
        case .mesh(let meshDocument):
            let meshService = MeshService(meshDocument, shouldSave: false)
            meshService.subdivsions = subdivisions
            return meshService.render(resolution: CGSize(width: resolution.width, height: resolution.height))
        case .scene(let sceneDocument):
            let sceneService = SceneService(sceneDocument, shouldSave: false)
            sceneService.sceneDocument.cameras[0].screenSpaceAmbientOcclusionOptions.intensity = ambientOcclusionIntensity
            return sceneService.render(resolution: CGSize(width: resolution.width, height: resolution.height), useAntialiasing: true)
        }
    }
}

extension CIImage {
    func resize(_ size: CGSize) -> CIImage? {
        let scale = Double(size.width) / Double(self.extent.size.width)
        let filter = CIFilter(name: "CILanczosScaleTransform")
        filter?.setValue(self, forKey: kCIInputImageKey)
        filter?.setValue(NSNumber(value: scale), forKey: kCIInputScaleKey)
        filter?.setValue(1.0, forKey:kCIInputAspectRatioKey)
        return filter?.value(forKey: kCIOutputImageKey) as? CIImage
    }
}
