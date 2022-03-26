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
        @State private var blurValue: Float = 0
        
        var body: some View {
            VStack {
                Text("Image Effects")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Text("Blur:")
                    Slider(value: $blurValue, in: 0...200) {
                        Text("")
                    } minimumValueLabel: {
                        Text("0%")
                    } maximumValueLabel: {
                        Text("200%")
                    }.labelsHidden()
                }
            }
        }
    }
}
