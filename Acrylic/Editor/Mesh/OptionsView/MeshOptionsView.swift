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
    @Environment(\.horizontalSizeClass) var horizontalClass
    
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
            } else if horizontalClass == .compact && UIDevice.current.userInterfaceIdiom != .mac {
                VStack(spacing: 0) {
                    HStack {
                        if let closeAction = closeAction {
                            Button {
                                closeAction()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.title3.bold())
                            }
                        }
                        
                        Text(meshService.meshDocument?.fileURL.deletingPathExtension().lastPathComponent ?? "Mesh Gradient")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Button {
                            renderImage = meshService.render(resolution: CGSize(width: 8000, height: 8000))
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3.bold())
                        }
                    }
                    .padding(.horizontal, 30)
                    .frame(height: 60)
                    Divider()
                        .opacity(0.5)
                    scrollView
                }
                .navigationBarHidden(true)
            } else {
               VStack(spacing: 0) {
                   Divider()
                       .opacity(0.5)
                   scrollView
               }
               .navigationBarHidden(true)
           }
        }.sheet(item: $renderImage) { renderImage in
            ExportView(renderImage: renderImage)
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
                DetailsView()
                ViewportView()
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
