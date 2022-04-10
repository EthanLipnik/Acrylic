//
//  MeshEditorCompactView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/26/21.
//

import SwiftUI

struct MeshEditorCompactView: View {
    @EnvironmentObject var meshService: MeshService
    
    @State private var isShowingColorsView: Bool = false
    @State private var isShowingViewportView: Bool = false
    @State private var isShowingDetailView: Bool = false
    
    @State private var renderImage: UIImage? = nil
    
    @Namespace var nspace
    
    var closeAction: () -> Void
    
    var body: some View {
        ZStack {
            EditorView()
                .ignoresSafeArea()
                .id("editor")
            VStack {
                HStack(alignment: .top) {
                    if isShowingDetailView {
                        MeshOptionsView.DetailsView(withBackground: false)
                            .environmentObject(meshService)
                            .overlay(
                                Button(action: {
                                    withAnimation(.spring()) {
                                        isShowingDetailView.toggle()
                                        isShowingColorsView = false
                                        isShowingViewportView = false
                                    }
                                }, label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3.bold())
                                        .padding()
                                }), alignment: .topTrailing)
                            .background(BlurView(style: .roundedRectangle(cornerRadius: 20), effect: .ultraThin)
                                .shadow(radius: 30)
                                .matchedGeometryEffect(id: "detailsView-background", in: nspace))
                            .matchedGeometryEffect(id: "detailsView", in: nspace)
                            .transition(.scale(scale: isShowingViewportView ? 0 : 0.9, anchor: .topLeading))
                    } else {
                        Button {
                            withAnimation(.spring()) {
                                isShowingDetailView.toggle()
                                isShowingColorsView = false
                                isShowingViewportView = false
                            }
                        } label: {
                            Image(systemName: "sparkles")
                                .font(.title3.bold())
                                .padding()
                        }
                        .background(BlurView(style: .circle)
                            .shadow(radius: 30)
                            .matchedGeometryEffect(id: "detailsView-background", in: nspace))
                        .matchedGeometryEffect(id: "detailsView", in: nspace)
                    }
                    Spacer()
                    Button {
                        renderImage = meshService.render()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3.bold())
                            .padding()
                    }
                    .background(BlurView(style: .circle)
                        .shadow(radius: 30))
                    
                }
                
                Spacer()
                HStack(alignment: .bottom) {
                    if isShowingViewportView {
                        MeshOptionsView.ViewportView(withBackground: false)
                            .environmentObject(meshService)
                            .overlay(
                                Button(action: {
                                    withAnimation(.spring()) {
                                        isShowingViewportView.toggle()
                                        isShowingColorsView = false
                                        isShowingDetailView = false
                                    }
                                }, label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3.bold())
                                        .padding()
                                }), alignment: .topTrailing)
                            .background(BlurView(style: .roundedRectangle(cornerRadius: 20), effect: .ultraThin)
                                .shadow(radius: 30)
                                .matchedGeometryEffect(id: "viewportView-background", in: nspace))
                            .matchedGeometryEffect(id: "viewportView", in: nspace)
                            .transition(.scale(scale: isShowingViewportView ? 0 : 0.9, anchor: .bottomLeading))
                    } else {
                        Button {
                            withAnimation(.spring()) {
                                isShowingViewportView.toggle()
                                isShowingColorsView = false
                                isShowingDetailView = false
                            }
                        } label: {
                            Image(systemName: "viewfinder")
                                .font(.title3.bold())
                                .padding()
                        }
                        .background(BlurView(style: .circle)
                            .shadow(radius: 30)
                            .matchedGeometryEffect(id: "viewportView-background", in: nspace))
                        .matchedGeometryEffect(id: "viewportView", in: nspace)
                    }
                    Spacer()
                    if isShowingColorsView {
                        MeshOptionsView.SelectionView(withBackground: false) {
                            for i in 0..<meshService.colors.count {
                                meshService.colors[i].color = UIColor.white
                            }
                        }
                        .environmentObject(meshService)
                        .overlay(
                            Button(action: {
                                withAnimation(.spring()) {
                                    isShowingColorsView.toggle()
                                    isShowingViewportView = false
                                    isShowingDetailView = false
                                }
                            }, label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3.bold())
                                    .padding()
                            }), alignment: .topTrailing)
                        .background(BlurView(style: .roundedRectangle(cornerRadius: 20), effect: .ultraThin)
                            .shadow(radius: 30)
                            .matchedGeometryEffect(id: "colorsView-background", in: nspace))
                        .matchedGeometryEffect(id: "colorsView", in: nspace)
                        .transition(.scale(scale: isShowingColorsView ? 0 : 0.9, anchor: .bottomTrailing))
                    } else {
                        Button {
                            withAnimation(.spring()) {
                                isShowingColorsView.toggle()
                                isShowingViewportView = false
                                isShowingDetailView = false
                            }
                        } label: {
                            Image(systemName: "paintbrush")
                                .font(.title3.bold())
                                .padding()
                        }
                        .background(BlurView(style: .circle)
                            .shadow(radius: 30)
                            .matchedGeometryEffect(id: "colorsView-background", in: nspace))
                        .matchedGeometryEffect(id: "colorsView", in: nspace)
                    }
                }
            }.padding()
        }
        .navigationTitle(meshService.meshDocument?.fileURL.deletingPathExtension().lastPathComponent ?? "Mesh Gradient")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    closeAction()
                } label: {
                    Label("Done", systemImage: "xmark.circle.fill")
                }
            }
        }
        .sheet(item: $renderImage) { renderImage in
            ExportView(renderImage: renderImage, meshService: meshService)
        }
    }
}

struct CompactView_Previews: PreviewProvider {
    static var previews: some View {
        MeshEditorCompactView {}
    }
}
