//
//  ExportView+ExportOptionsView.swift
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
        @State private var imageDocument: ImageDocument? = nil
        
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
                        switch exportService.export() {
                        case .success(let document):
                            imageDocument = document
                            
                            isExportingImage.toggle()
                        case .failure(let error):
                            print(error)
                        }
                    }
                    .keyboardShortcut(.defaultAction)
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
                        ShareSheet(activityItems: [UIImage(data: document.imageData)!])
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
