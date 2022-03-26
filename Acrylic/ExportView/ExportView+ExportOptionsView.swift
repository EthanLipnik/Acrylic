//
//  ExportView+ExportOptionsView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/25/22.
//

import Foundation
import SwiftUI

extension ExportView {
    struct ExportOptionsView: View {
        @EnvironmentObject var exportService: ExportService
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            VStack {
                GroupBox {
                    VStack {
                        FormatView()
                        Divider()
                        ResolutionView()
                        Divider()
                        ImageEffectsView()
                    }.padding(10)
                    Spacer()
                }
                HStack {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
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
