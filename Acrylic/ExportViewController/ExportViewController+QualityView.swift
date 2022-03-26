//
//  ExportViewController+QualityView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/25/22.
//

import Foundation
import SwiftUI

extension ExportViewController {
    struct QualityView: View {
        @State private var subdivisions: Float = 18
        
        var body: some View {
            VStack {
                Text("Quality")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Text("Subdivisions:")
                    Slider(value: $subdivisions, in: 4...64, step: 1) {
                        Text("")
                    } minimumValueLabel: {
                        Text("4")
                    } maximumValueLabel: {
                        Text("64")
                    }.labelsHidden()
                }
                
                VStack {
                    
                }
            }
        }
    }
}
