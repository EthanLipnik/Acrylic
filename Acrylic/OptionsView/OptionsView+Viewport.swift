//
//  OptionsView+Viewport.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/24/21.
//

import SwiftUI

extension OptionsView {
    var viewport: some View {
        DetailView(title: "Viewport", systemImage: "viewfinder") {
            Toggle(isOn: $meshService.isRenderingAsWireframe) {
                Label("Show as Wireframe", systemImage: "squareshape.split.2x2.dotted")
            }
            .toggleStyle(.switch)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct OptionsView_Viewport_Previews: PreviewProvider {
    static var previews: some View {
        OptionsView().viewport
    }
}
