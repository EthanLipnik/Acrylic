//
//  ExportView+OptionsView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/25/22.
//

import Foundation
import SwiftUI

extension ExportView {
    struct ExportOptionsView: View {
        @EnvironmentObject var exportService: ExportService
        @Environment(\.presentationMode) var presentationMode

        @State private var isExportingImage: Bool = false
        @State private var imageDocument: ImageDocument?

#if !targetEnvironment(macCatalyst)
        @State private var fileUrl: URL?
#endif

        var body: some View {
            VStack {
                GroupBox {
                    ScrollView {
                        VStack {
                            FormatView()
                            Divider()
                            ResolutionView()
                            Divider()
                            ImageEffectsView()
                        }.padding(10)
                        Spacer()
                    }
#if !targetEnvironment(macCatalyst)
                    .padding(-10)
#endif
                }
                HStack {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                    Spacer()
                    Button("Export") {
                        exportService.export { result in
                            switch result {
                            case .success(let imageDocument):
                                DispatchQueue.main.async {
                                    self.imageDocument = imageDocument

#if !targetEnvironment(macCatalyst)
                                    do {
                                        let fileUrl = FileManager.default.temporaryDirectory.appendingPathComponent("image." + exportService.format.fileExtension)
                                        try imageDocument.imageData.write(to: fileUrl)
                                        self.fileUrl = fileUrl
                                    } catch {
                                        print(error)
                                    }
#endif

                                    self.isExportingImage.toggle()
                                }
                            case .failure(let error):
                                print(error)
                            }
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(exportService.isProcessing)
#if targetEnvironment(macCatalyst)
                    .fileExporter(isPresented: $isExportingImage, document: imageDocument, contentType: exportService.format.type) { result in
                        switch result {
                        case .success(let url):
                            print(url.path)

                            presentationMode.wrappedValue.dismiss()
                        case .failure(let error):
                            print(error)
                        }
                    }
#else
                    .sheet(item: $imageDocument) { document in
                        ShareSheet(activityItems: [fileUrl ?? UIImage(data: document.imageData) as Any])
                            .onDisappear {
                                presentationMode.wrappedValue.dismiss()
                            }
                    }
#endif
                }
            }
        }
    }
}
