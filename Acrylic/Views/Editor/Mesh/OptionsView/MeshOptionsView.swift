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
    
    let isCompact: Bool
    var closeAction: (() -> Void)? = nil
    @State private var isExporting: Bool = false
    @State private var isClearingColors: Bool = false
    
    var body: some View {
        Group {
            if isCompact && UIDevice.current.userInterfaceIdiom != .mac {
                ZStack(alignment: .top) {
                    scrollView
                    HStack {
                        if let closeAction = closeAction {
                            Button {
                                closeAction()
                            } label: {
                                Text("Close")
                                    .font(.body)
                                    .frame(height: 60)
                            }
                        }
                        
                        Text(meshService.meshDocument?.fileURL.deletingPathExtension().lastPathComponent ?? "Mesh")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(height: 60)
                        
                        Button {
                            isExporting.toggle()
                        } label: {
                            Text("Export")
                                .font(.headline)
                                .frame(height: 60)
                        }
                    }
                    .padding(.horizontal, 30)
                    .background(VisualEffectBlur(blurStyle: .regular))
                    .overlay(Divider().opacity(0.5), alignment: .bottom)
                }
                .navigationBarHidden(true)
            } else if UIDevice.current.userInterfaceIdiom != .mac {
                scrollView
                    .background(Color(.secondarySystemBackground).ignoresSafeArea())
                    .navigationTitle(meshService.meshDocument?.fileURL.deletingPathExtension().lastPathComponent ?? "Mesh")
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
        }
        .sheet(isPresented: $isExporting) {
            Group {
                if let meshDocument = meshService.meshDocument {
                    ExportView(document: .mesh(meshDocument))
                } else {
                    Text("No document")
                        .padding()
                }
            }
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
                SelectionView {
                    isClearingColors.toggle()
                }
                .alert(isPresented: $isClearingColors, content: {
                    Alert(title: Text("Are you sure?"),
                          message: Text("You cannot undo this action."),
                          primaryButton: Alert.Button.destructive(Text("Clear colors"), action: clearColors),
                          secondaryButton: Alert.Button.cancel())
                })
                DetailsView()
                ViewportView()
            }
            .padding()
            .padding(.top, isCompact && UIDevice.current.userInterfaceIdiom != .mac ? 60 : 0)
            .animation(.spring(), value: meshService.selectedPoint)
        }
    }
}

struct OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        MeshOptionsView(isCompact: false) { // Close action
            
        }
    }
}

extension UIImage: Identifiable {
    public var id: String {
        return self.description
    }
}

extension MeshScene {
    static func fromMeshService(_ meshService: MeshService) -> MeshScene {
        let scene = MeshScene()
        scene.create(meshService.colors,
                     width: meshService.width,
                     height: meshService.height,
                     subdivisions: meshService.subdivsions)
        return scene
    }
}
