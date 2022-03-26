//
//  ExportViewController+ResolutionView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/25/22.
//

import Foundation
import SwiftUI

extension ExportViewController {
    struct ResolutionView: View {
        
        @State private var width: String = "4096"
        
        var body: some View {
            VStack {
                Text("Resolution")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Text("Width:")
                    TextField("ex) 4096", text: $width)
                        .textFieldStyle(.roundedBorder)
                    Text("px")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Height:")
                    TextField("ex) 4096", text: $width)
                        .textFieldStyle(.roundedBorder)
                    Text("px")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
