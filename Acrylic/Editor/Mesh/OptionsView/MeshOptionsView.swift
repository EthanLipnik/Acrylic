//
//  MeshOptionsView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import SwiftUI
import MeshKit
import UniformTypeIdentifiers

struct MeshOptionsView: View {
    @EnvironmentObject var meshService: MeshService
    
    var closeAction: (() -> Void)? = nil
    @State private var renderImage: UIImage? = nil
    
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                scrollView
                    .background(Color(.secondarySystemBackground).ignoresSafeArea())
                    .navigationTitle(meshService.meshDocument?.fileURL.deletingPathExtension().lastPathComponent ?? "Mesh Gradient")
                    .toolbar {
                        ToolbarItem(placement: .navigation) {
                            if let closeAction = closeAction {
                                Button {
                                    closeAction()
                                } label: {
                                    Label("Done", systemImage: "xmark.circle.fill")
                                }
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
        }.sheet(item: $renderImage) { renderImage in
            ExportView(renderImage: renderImage, meshService: meshService)
        }
    }
    
    var exportButton: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                renderImage = meshService.render()
            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
            }
        }
    }
    
    func clearColors() {
        for i in 0..<meshService.colors.count {
            meshService.colors[i].color = UIColor.white
        }
    }
    
    func randomizeColors() {
        meshService.generate(Palette: .randomPalette())
    }
    
    var scrollView: some View {
        ScrollView {
            VStack {
                SelectionView(clearColorsAction: clearColors)
                    .environmentObject(meshService)
                DetailsView()
                    .environmentObject(meshService)
                ViewportView()
                    .environmentObject(meshService)
            }
            .padding()
            .animation(.spring(), value: meshService.selectedPoint)
        }
    }
}

struct OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        MeshOptionsView { // Close action
            
        }
    }
}

extension UIImage: Identifiable {
    public var id: String {
        return self.description
    }
}
