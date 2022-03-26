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
        @EnvironmentObject var exportService: ExportService
        
        var body: some View {
            VStack {
                GroupBox {
                    VStack {
                        FormatView()
                        Divider()
                        ResolutionView()
                        Divider()
                        ImageEffectsView()
                        Divider()
                        QualityView()
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
