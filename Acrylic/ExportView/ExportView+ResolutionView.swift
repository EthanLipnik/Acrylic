//
//  ExportView+ResolutionView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/25/22.
//

import Foundation
import SwiftUI

extension ExportView {
    struct ResolutionView: View {
        @EnvironmentObject var exportService: ExportService
        
        @State private var width: String = "4096"
        @State private var height: String = "4096"
        
        var body: some View {
            VStack {
                Text("Resolution")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Text("Width:")
                        .frame(width: 90, alignment: .leading)
                    TextField("ex) 4096", text: $width)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                    Text("px")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                HStack {
                    Text("Height:")
                        .frame(width: 90, alignment: .leading)
                    TextField("ex) 4096", text: $height)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                    Text("px")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .onChange(of: width, perform: { newValue in
                exportService.resolution.width = Float(newValue) ?? 1
            })
            .onChange(of: height, perform: { newValue in
                exportService.resolution.height = Float(newValue) ?? 1
            })
            .contextMenu {
                Button("6k") {
                    width = "6100"
                    height = width
                }
                
                Button("4k") {
                    width = "4096"
                    height = width
                }
                
                Button("1080p") {
                    width = "1920"
                    height = width
                }
                
                Button("720p") {
                    width = "1280"
                    height = width
                }
                Divider()
                Button("480p") {
                    width = "640"
                    height = width
                }
            }
        }
    }
}
