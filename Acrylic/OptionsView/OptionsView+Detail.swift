//
//  OptionsView+Detail.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/24/21.
//

import SwiftUI

extension OptionsView {
    var detailsView: some View {
        DetailView(title: "Detail", systemImage: "sparkles") {
            HStack {
                Label("Subdivsions", systemImage: "rectangle.split.3x3.fill")
                Slider(value: subdivsionsIntProxy, in: 4.0...36.0, step: 2.0)
                Text("\(meshService.subdivsions)")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(Color.secondary)
            }
            .animation(.spring(), value: meshService.subdivsions)
            .contextMenu {
                Button("Reset") {
                    withAnimation {
                        meshService.subdivsions = 18
                    }
                }
            }
            
            HStack {
                Label("Scale Factor", systemImage: "arrow.up.left.and.arrow.down.right")
                Slider(value: $meshService.contentScaleFactor, in: 1.0...50.0)
                Text(String(format: "%.1f", meshService.contentScaleFactor))
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(Color.secondary)
            }
            .animation(.spring(), value: meshService.contentScaleFactor)
            .contextMenu {
                Button("Reset") {
                    withAnimation {
                        meshService.contentScaleFactor = 1
                    }
                }
            }
        }
    }
}
