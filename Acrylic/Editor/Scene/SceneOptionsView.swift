//
//  SceneOptionsView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 4/10/22.
//

import SwiftUI

struct SceneOptionsView: View {
    @EnvironmentObject var sceneService: SceneService
    
    var closeAction: () -> Void
    
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                scrollView
                    .background(Color(.secondarySystemBackground).ignoresSafeArea())
                    .navigationTitle(sceneService.sceneDocument.fileURL.deletingPathExtension().lastPathComponent)
                    .toolbar {
                        ToolbarItem(placement: .navigation) {
                            Button {
                                closeAction()
                            } label: {
                                Label("Done", systemImage: "xmark.circle.fill")
                            }
                        }
                        
                        exportButton
                    }
            } else {
                VStack(spacing: 0) {
                    Divider()
                        .opacity(0.5)
                    scrollView
                }
                .navigationBarHidden(true)
            }
        }
    }
    
    var scrollView: some View {
        ScrollView {
            VStack {
                PresetView()
            }.padding()
        }
    }
    
    var exportButton: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
            }
        }
    }
}

struct SceneOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        SceneOptionsView() {}
    }
}
