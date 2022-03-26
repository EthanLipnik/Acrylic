//
//  ExportViewController+ExportOptionsView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/25/22.
//

import Foundation
import SwiftUI

extension ExportViewController {
    struct ExportOptionsView: View {
        var body: some View {
            VStack {
                GroupBox {
                    VStack {
                        FormatView()
                        Divider()
                        ImageEffectsView()
                        Divider()
                        QualityView()
                        Divider()
                        ResolutionView()
                    }.padding(10)
                    Spacer()
                }
                HStack {
                    Button("Cancel") {
                        
                    }
                    .keyboardShortcut(.cancelAction)
                    Spacer()
                    Button("Export") {
                        
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
        }
    }
}
