//
//  ExportViewController+Format.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/25/22.
//

import Foundation
import SwiftUI

extension ExportViewController.ExportOptionsView {
    struct FormatView: View {
        
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
        
        @State private var selectedFormat: Format = .png
        @State private var compressionQuality: Float = 1
        
        var body: some View {
            VStack {
                Text("File")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Picker("Format:", selection: $selectedFormat) {
                    ForEach(Format.allCases, id: \.rawValue) {
                        Text($0.rawValue)
                            .tag($0)
                    }
                }
                
                if selectedFormat.hasCompression {
                    HStack {
                        Text("Compression Quality:")
                        Slider(value: $compressionQuality, in: 0...1) {
                            Text("")
                        } minimumValueLabel: {
                            Text("0%")
                        } maximumValueLabel: {
                            Text("100%")
                        }.labelsHidden()
                    }
                }
            }
        }
    }
}
