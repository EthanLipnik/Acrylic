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
            DetailView(title: "Points", systemImage: "circle.grid.3x3") {
                HStack {
                    Label("Horizontal", systemImage: "arrow.left.arrow.right")
                    Slider(value: widthIntProxy, in: 3.0...6.0, step: 1.0)
                    Text("\(meshService.width)")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(Color.secondary)
                }
                HStack {
                    Label("Height", systemImage: "arrow.up.arrow.down")
                    Slider(value: heightIntProxy, in: 3.0...6.0, step: 1.0)
                    Text("\(meshService.height)")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(Color.secondary)
                }
            }
        }
    }
}
