//
//  SceneOptionsView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 4/10/22.
//

import SwiftUI

struct SceneOptionsView: View {
    @EnvironmentObject var sceneService: SceneService
    
    let isCompact: Bool
    var closeAction: () -> Void
    @State private var isExporting: Bool = false
    
    var body: some View {
        Group {
            if isCompact && UIDevice.current.userInterfaceIdiom != .mac {
                ZStack(alignment: .top) {
                    scrollView
                    HStack {
                        Button {
                            closeAction()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title3.bold())
                        }

                        Text(sceneService.sceneDocument.fileURL.deletingPathExtension().lastPathComponent)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Button {
                            isExporting.toggle()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3.bold())
                        }
                    }
                    .padding(.horizontal, 30)
                    .frame(height: 60)
                    .background(VisualEffectBlur(blurStyle: .regular))
                    .overlay(Divider().opacity(0.5), alignment: .bottom)
                }
                .navigationBarHidden(true)
            } else if UIDevice.current.userInterfaceIdiom != .mac {
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
        .sheet(isPresented: $isExporting) {
            ExportView(document: Document.scene(sceneService.sceneDocument))
        }
    }
    
    var scrollView: some View {
        ScrollView {
            VStack {
                PresetView()
                CameraView()
            }
            .padding()
            .padding(.top, isCompact && UIDevice.current.userInterfaceIdiom != .mac ? 60 : 0)
        }
    }
    
    var exportButton: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                isExporting.toggle()
            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
            }
        }
    }
}

struct SceneOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        SceneOptionsView(isCompact: false) {}
    }
}
