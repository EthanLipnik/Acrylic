//
//  MeshOptionsView+Viewport.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/24/21.
//

import SwiftUI

extension MeshOptionsView {
    struct ViewportView: View {
        @EnvironmentObject var meshService: MeshService
        
        var withBackground: Bool = true
        
        var body: some View {
            DetailView(title: "Viewport", systemImage: "viewfinder", withBackground: withBackground) {
                Toggle(isOn: $meshService.isRenderingAsWireframe) {
                    Label("Show as Wireframe", systemImage: "squareshape.split.2x2.dotted")
                }
                .toggleStyle(.switch)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct OptionsView_Viewport_Previews: PreviewProvider {
    static var previews: some View {
        MeshOptionsView.ViewportView()
    }
}
