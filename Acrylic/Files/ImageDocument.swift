//
//  ImageDocument.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/21/22.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ImageDocument: FileDocument, Identifiable {
    static var readableContentTypes: [UTType] { [.image, .png, .jpeg, .heic, .heif] }

    var id: String { fileName }

    var imageData: Data
    var fileName: String

    init(imageData: Data, fileName: String = "Render") {
        self.imageData = imageData
        self.fileName = fileName
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }

        self.imageData = data
        self.fileName = "Render"
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let fileWrapper = FileWrapper(regularFileWithContents: imageData)
        fileWrapper.filename = fileName
        return fileWrapper
    }

    func snapshot(contentType: UTType) throws -> Data {
        return imageData
    }
}
