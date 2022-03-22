//
//  ImageDocument.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/21/22.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ImageDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.image, .png, .jpeg] }
    
    var imageData: Data
    
    init(imageData: Data) {
        self.imageData = imageData
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        self.imageData = data
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let fileWrapper = FileWrapper(regularFileWithContents: imageData)
        return fileWrapper
    }
    
    func snapshot(contentType: UTType) throws -> Data {
        return imageData
    }
}
