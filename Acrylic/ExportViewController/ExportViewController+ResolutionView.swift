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
                    TextField("ex) 4096", text: $width)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                    Text("px")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
    }
}
