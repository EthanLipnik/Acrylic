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
    
    var previewImage: UIImage? = nil
    
    private struct JSONModel: Codable {
        var colors: [MeshNode.Color]
        var width: Int
        var height: Int
        var subdivisions: Int
        var previewImage: String? = nil
        
        init(_ document: MeshDocument) {
            self.colors = document.colors
            self.width = document.width
            self.height = document.height
            self.subdivisions = document.subdivisions
            
            if let previewImage = try? document.previewImage?.heicData(compressionQuality: 0.8) as? NSData {
                do {
                    self.previewImage = try previewImage.compressed(using: .zlib).base64EncodedString()
                } catch {
                    print(error)
                }
            }
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
        // Encode your document with an instance of NSData or NSFileWrapper
        return try JSONEncoder().encode(JSONModel(self))
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
        guard let data = contents as? Data else { throw CocoaError(.fileReadUnknownStringEncoding) }
        
        let model = try JSONDecoder().decode(JSONModel.self, from: data)
        self.colors = model.colors
        self.width = model.width
        self.height = model.height
        self.subdivisions = model.subdivisions
        
        if let base64 = model.previewImage,
           let data = NSData(base64Encoded: base64),
           let decompressedData = try? data.decompressed(using: .zlib),
           let image = UIImage(data: decompressedData as Data) {
            self.previewImage = image
        }
    }
}
