//
//  CompactView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/26/21.
//

import SwiftUI
import VisualEffects

struct CompactView: View {
    @StateObject var meshService: MeshService = {
        let scene = UIApplication.shared.connectedScenes.first
        if let sceneDelegate = scene?.delegate as? SceneDelegate {
            return sceneDelegate.meshService
        } else {
            return .init()
        }
    }()
    
    @State private var isShowingColorsView: Bool = false
    
    @Namespace var nspace
    
    var body: some View {
        ZStack {
            EditorView()
                .ignoresSafeArea()
                .id("editor")
            VStack {
                HStack {
                    Spacer()
                    Button {
                        let scene = UIApplication.shared.connectedScenes.first
                        if let sceneDelegate = scene?.delegate as? SceneDelegate {
                            sceneDelegate.export()
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3.bold())
                            .padding()
                    }
                    .background(VisualEffectBlur()
                                    .clipShape(Circle())
                                    .shadow(radius: 30))
                    
                }
                
                Spacer()
                HStack {
                    Spacer()
                    if isShowingColorsView {
                        OptionsView.SelectionView(withBackground: false) {
                            for i in 0..<meshService.colors.count {
                                meshService.colors[i].color = UIColor.white
                            }
                        } randomizeColorsAction: {
                            meshService.randomizePointsAndColors()
                        }
                        .environmentObject(meshService)
                        .overlay(
                            Button(action: {
                                withAnimation(.spring()) {
                                    isShowingColorsView.toggle()
                                }
                            }, label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3.bold())
                                    .padding()
                            }), alignment: .topTrailing)
                        .background(VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                        .shadow(radius: 30)
                                        .matchedGeometryEffect(id: "colorsView-background", in: nspace))
                        .matchedGeometryEffect(id: "colorsView", in: nspace)
                        .transition(.scale(scale: isShowingColorsView ? 0 : 0.9, anchor: .bottomTrailing))
                    } else {
                        Button {
                            withAnimation(.spring()) {
                                isShowingColorsView.toggle()
                            }
                        } label: {
                            Image(systemName: "paintbrush")
                                .font(.title3.bold())
                                .padding()
                        }
                        .background(VisualEffectBlur()
                                        .clipShape(Circle())
                                        .shadow(radius: 30)
                                        .matchedGeometryEffect(id: "colorsView-background", in: nspace))
                        .matchedGeometryEffect(id: "colorsView", in: nspace)
                    }
                }
            }.padding()
        }
    }
}

struct CompactView_Previews: PreviewProvider {
    static var previews: some View {
        CompactView()
    }
}
