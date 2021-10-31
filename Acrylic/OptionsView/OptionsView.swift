//
//  OptionsView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import SwiftUI
import MeshKit
import UniformTypeIdentifiers

struct OptionsView: View {
    @StateObject var meshService: MeshService = {
        let scene = UIApplication.shared.connectedScenes.first
        if let sceneDelegate = scene?.delegate as? SceneDelegate {
            return sceneDelegate.meshService
        } else {
            return .init()
        }
    }()
    
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .phone {
                NavigationView {
                    scrollView
                        .background(Color(.secondarySystemBackground).ignoresSafeArea())
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle("Options")
                        .toolbar {
                            exportButton
                        }
                }
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .ignoresSafeArea()
                .shadow(radius: 30, y: -10)
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
    
    var exportButton: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                let scene = UIApplication.shared.connectedScenes.first
                if let sceneDelegate = scene?.delegate as? SceneDelegate {
                    sceneDelegate.export()
                }
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
        meshService.randomizePointsAndColors()
    }
    
    var scrollView: some View {
        ScrollView {
            VStack {
                SelectionView(clearColorsAction: clearColors, randomizeColorsAction: randomizeColors)
                    .environmentObject(meshService)
                DetailsView()
                    .environmentObject(meshService)
                ViewportView()
                    .environmentObject(meshService)
                renderView
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Button("Export") {
                        let scene = UIApplication.shared.connectedScenes.first
                        if let sceneDelegate = scene?.delegate as? SceneDelegate {
                            sceneDelegate.export()
                        }
                    }
                }
            }
            .padding()
            .animation(.spring(), value: meshService.selectedPoint)
        }
    }
}

struct OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        OptionsView()
    }
}

struct ColorPickerView: UIViewControllerRepresentable {
    let color: UIColor
    let selectColor: (UIColor) -> Void
    
    func makeUIViewController(context: Context) -> UIColorPickerViewController {
        let vc = UIColorPickerViewController()
        
        vc.selectedColor = color
        vc.supportsAlpha = false
        vc.delegate = context.coordinator
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIColorPickerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, selectColor: selectColor)
    }
    
    class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
        var parent: ColorPickerView
        let selectColor: (UIColor) -> Void
        
        init(_ parent: ColorPickerView, selectColor: @escaping (UIColor) -> Void) {
            self.parent = parent
            self.selectColor = selectColor
        }
        
        func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        }
        
        func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
            
            selectColor(color)
        }
    }
}
