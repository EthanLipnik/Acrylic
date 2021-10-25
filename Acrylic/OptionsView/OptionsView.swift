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
    @ObservedObject var meshService: MeshService = {
        let scene = UIApplication.shared.connectedScenes.first
        if let sceneDelegate = scene?.delegate as? SceneDelegate {
            return sceneDelegate.meshService
        } else {
            return .init()
        }
    }()
    
    var subdivsionsIntProxy: Binding<Double>{
        Binding<Double>(get: {
            //returns the score as a Double
            return Double(meshService.subdivsions)
        }, set: {
            //rounds the double to an Int
            meshService.subdivsions = Int($0)
        })
    }
    
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
#if !targetEnvironment(macCatalyst)
                .toolbar {
                    exportButton
                }
#endif
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
        for i in 0..<meshService.colors.count {
            meshService.colors[i].color = UIColor(hue: CGFloat(drand48()), saturation: 0.8, brightness: 1, alpha: 1)
        }
    }
    
    var scrollView: some View {
        ScrollView {
            VStack {
                colorsView
                detailsView
                viewport
            }
            .padding()
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
            
            viewController.dismiss(animated: true)
        }
    }
}
