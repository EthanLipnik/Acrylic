//
//  ExportView+ImageEffectsView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/25/22.
//

import Foundation
import SwiftUI

extension ExportView {
    struct ImageEffectsView: View {
        @EnvironmentObject var exportService: ExportService
        
        var body: some View {
            VStack {
                Text("Effects")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Text("Blur:")
                        .frame(width: 90, alignment: .leading)
                    Slider(value: $exportService.blur, in: 0...100) {
                        Text("")
                    }.labelsHidden()
                }
                
                switch exportService.document {
                case .mesh:
                    MeshEffectsView()
                case .scene:
                    EmptyView()
                }
            }
        }
    }
    
    struct MeshEffectsView: View {
        @EnvironmentObject var exportService: ExportService
        
        var subdivisionsIntProxy: Binding<Double>{
            Binding<Double>(get: {
                //returns the score as a Double
                return Double(exportService.subdivisions)
            }, set: {
                //rounds the double to an Int
                exportService.subdivisions = Int($0)
            })
        }
        
        var body: some View {
            Group {
                HStack {
                    Text("Subdivisions:")
                        .frame(width: 100, alignment: .leading)
                    Slider(value: subdivisionsIntProxy, in: 4...128, step: 1) {
                        Text("Subdivisions")
                    }.labelsHidden()
                }
            }
        }
    }
}
