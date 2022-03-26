//
//  ExportViewController+ImageEffectsView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/25/22.
//

import Foundation
import SwiftUI

extension ExportViewController {
    struct ImageEffectsView: View {
        @EnvironmentObject var exportService: ExportService
        
        var body: some View {
            VStack {
                Text("Image Effects")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Text("Blur:")
                        .frame(width: 90, alignment: .leading)
                    Slider(value: $exportService.blur, in: 0...200) {
                        Text("")
                    }.labelsHidden()
                }
            }
        }
    }
}
