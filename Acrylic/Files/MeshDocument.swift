//
//  MeshDocument.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/27/22.
//

import UIKit
import UniformTypeIdentifiers
import MeshKit

extension UTType {
    static var acrylicMeshGradient: UTType {
        UTType(importedAs: "com.acrylic.mesh-gradient")
    }
}

class MeshDocument: UIDocument {
    lazy var colors: [MeshNode.Color] = MeshService.generateColors(palette: [.randomPalette()],
                                                              width: width,
                                                              height: height,
                                                              shouldRandomizePointLocations: false)
    var width: Int = 3
    var height: Int = 3
    var subdivisions: Int = 18
    
    var previewImage: Data? = nil
    
    private struct MeshDescriptorModel: Codable {
        var colors: [MeshNode.Color]
        var width: Int
        var height: Int
        var subdivisions: Int
        
        init(_ document: MeshDocument) {
            self.colors = document.colors
            self.width = document.width
            self.height = document.height
            self.subdivisions = document.subdivisions
        }
    }
    
    init(colors: [MeshNode.Color] = [],
         width: Int = 3,
         height: Int = 3,
         subdivisions: Int = 18,
         fileURL url: URL = AppDelegate.documentsFolder.appendingPathComponent("Mesh" + UTType.acrylicMeshGradient.preferredFilenameExtension!)) {
        super.init(fileURL: url)
        
        if !colors.isEmpty {
            self.colors = colors
        }
        self.width = width
        self.height = height
        self.subdivisions = subdivisions
    }
    
    override init(fileURL url: URL) {
        super.init(fileURL: url)
    }
    
    override func contents(forType typeName: String) throws -> Any {
        let meshDescriptor = MeshDescriptorModel(self)
        let meshDescriptorJSON = try JSONEncoder().encode(meshDescriptor)
        let compressedmeshDescriptor = try (meshDescriptorJSON as NSData).compressed(using: .zlib)
        let meshDescriptorFile = FileWrapper(regularFileWithContents: compressedmeshDescriptor as Data)
        meshDescriptorFile.preferredFilename = "MeshDescriptor"
        
        var fileWrappers: [String: FileWrapper] = ["MeshDescriptor": meshDescriptorFile]
        
        if let previewImage = previewImage {
            let previewImageFile = FileWrapper(regularFileWithContents: previewImage)
            fileWrappers["PreviewImage.heic"] = previewImageFile
        }
        return FileWrapper(directoryWithFileWrappers: fileWrappers)
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let topFileWrapper = contents as? FileWrapper,
              let compressedMeshDescriptor = topFileWrapper.fileWrappers?["MeshDescriptor"]?.regularFileContents as? NSData else {
            return
        }
        
        let decompressedMeshDescriptor = try compressedMeshDescriptor.decompressed(using: .zlib) as Data
        let meshDescriptor = try JSONDecoder().decode(MeshDescriptorModel.self, from: decompressedMeshDescriptor)
        
        self.colors = meshDescriptor.colors
        self.width = meshDescriptor.width
        self.height = meshDescriptor.height
        self.subdivisions = meshDescriptor.subdivisions
        
        print(meshDescriptor)
        
        self.previewImage = topFileWrapper.fileWrappers?["PreviewImage.heic"]?.regularFileContents
    }
}
