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
        
        struct Resolution: Hashable, Identifiable {
            var id: String {
                return title
            }
            
            var title: String
            var size: Int
        }
        
        let resolutions: [Resolution] = [
            .init(title: "1k", size: 1024),
            .init(title: "2k", size: 2048),
            .init(title: "4k", size: 4096),
            .init(title: "5k", size: 5120),
            .init(title: "8k", size: 8192),
            .init(title: "10k", size: 10240)
        ].filter({ UIDevice.current.userInterfaceIdiom == .mac || $0.size <= 4096 })
        @State private var selectedResolution: Resolution = .init(title: "1k", size: 1024)
        
        var body: some View {
            VStack {
                Text("Quality")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Picker(selection: $selectedResolution) {
                    ForEach(resolutions) {
                        Text($0.title
                             + " (\($0.size)x\($0.size))"
                             + (($0.size > 2048 && UIDevice.current.userInterfaceIdiom != .mac) ? " [Experimental]" : ""))
                            .tag($0)
                    }
                } label: {
                    Text("Resolution:")
                        .frame(width: 90, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .onChange(of: selectedResolution) { newValue in
                    exportService.resolution = (CGFloat(newValue.size), CGFloat(newValue.size))
                }
            }
        }
    }
}
