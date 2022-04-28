//
//  OnboardingView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 4/27/22.
//

import SwiftUI
import MeshKit

struct OnboardingView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var meshService: MeshService = {
        let meshService = MeshService()
        meshService.width = 3
        meshService.height = 3
        
        return meshService
    }()
    
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    @State private var meshRender: UIImage? = nil
    
    var body: some View {
        ZStack {
            if let meshRender = meshRender {
                Image(uiImage: meshRender)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .id(meshRender)
                    .transition(.opacity)
            }
            VStack {
                VStack(spacing: 0) {
                    Image("Icon")
                        .resizable()
                        .aspectRatio(1/1, contentMode: .fit)
                        .frame(maxWidth: 150)
                    Text("Acrylic")
                        .font(.largeTitle.bold())
                        .shadow(radius: 15, y: 8)
                }
                VStack {
                    OptionsView.DetailView(title: "Mesh Gradients", systemImage: "square.fill", forceMacStyle: true) {
                        HStack {
                            Group {
                                if let meshRender = meshRender {
                                    Image(uiImage: meshRender)
                                        .resizable()
                                        .aspectRatio(1/1, contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                        .edgesIgnoringSafeArea(.all)
                                        .id(meshRender)
                                        .transition(.opacity.animation(.easeInOut(duration: 10)))
                                } else {
                                    SwiftUIMeshView().environmentObject(meshService)
                                        .aspectRatio(1/1, contentMode: .fit)
                                }
                            }
                            .shadow(radius: 15, y: 8)
                            Text("Create beautiful mesh gradients. Perfect for wallpapers.")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }.frame(height: 50)
                    }
                    OptionsView.DetailView(title: "Scenes", systemImage: "cube.fill", forceMacStyle: true) {
                        HStack {
                            SwiftUIMeshView().environmentObject(meshService)
                                .aspectRatio(1/1, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .shadow(radius: 15, y: 8)
                            Text("Easily design great looking 3D scenes.")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }.frame(height: 50)
                    }
                    OptionsView.DetailView(title: "Automation", systemImage: "square.stack.fill", forceMacStyle: true) {
                        HStack {
                            SwiftUIMeshView().environmentObject(meshService)
                                .aspectRatio(1/1, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .shadow(radius: 15, y: 8)
                            Text("Use Siri Shortcuts to automate your mesh gradients.")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }.frame(height: 50)
                    }
                }
                Spacer()
                Button("Continue") {
                    
                }
            }
            .padding()
            .onAppear {
                meshService.generate(Palette: .blue,
                                     luminosity: colorScheme == .light ? .bright : .dark,
                                     positionMultiplier: 0.5)
                withAnimation(.none) {
                    meshRender = meshService.render()
                }
            }
            .onReceive(timer) { input in
                meshService.generate(Palette: .blue,
                                     luminosity: colorScheme == .light ? .bright : .dark,
                                     positionMultiplier: 0.5)
                
                withAnimation(.easeInOut(duration: 4)) {
                    meshRender = meshService.render()
                }
            }
            .onChange(of: colorScheme) { newValue in
                meshService.generate(Palette: .blue,
                                     luminosity: newValue == .light ? .bright : .dark,
                                     positionMultiplier: 0.5)
                
                withAnimation(.easeInOut(duration: 0.4)) {
                    meshRender = meshService.render()
                }
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .preferredColorScheme(.light)
    }
}

struct SwiftUIMeshView: UIViewRepresentable {
    @EnvironmentObject var meshService: MeshService
    
    func makeUIView(context: Context) -> MeshView {
        let view = MeshView()
        view.create(meshService.colors, width: meshService.width, height: meshService.height, subdivisions: meshService.subdivsions)
        return view
    }
    
    func updateUIView(_ uiView: MeshView, context: Context) {
        uiView.create(meshService.colors, width: meshService.width, height: meshService.height, subdivisions: meshService.subdivsions)
    }
}
