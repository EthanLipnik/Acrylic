//
//  ExportView+Format.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/25/22.
//

import Foundation
import SwiftUI

extension ExportView {
    struct FormatView: View {
        @EnvironmentObject var exportService: ExportService
        
        var body: some View {
            VStack {
                Text("File")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Picker(selection: $exportService.format) {
                    ForEach(ExportService.Format.allCases, id: \.rawValue) {
                        Text($0.rawValue)
                            .tag($0)
                    }
                } label: {
                    Text("Format:")
                        .frame(width: 90, alignment: .leading)
                }
#if !targetEnvironment(macCatalyst)
                .pickerStyle(.segmented)
#endif
                
                if exportService.format.hasCompression {
                    HStack {
                        Text("Quality:")
                            .frame(width: 90, alignment: .leading)
                        Slider(value: $exportService.compressionQuality, in: 0...1) {
                            Text("")
                        }.labelsHidden()
                    }
                }
            }
        }
    }
}
