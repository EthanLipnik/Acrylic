//
//  OptionsView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import SwiftUI
import MeshKit

struct OptionsView: View {
    @ObservedObject var meshService: MeshService = {
        let scene = UIApplication.shared.connectedScenes.first
        if let sceneDelegate = scene?.delegate as? SceneDelegate {
            return sceneDelegate.meshService
        } else {
            return .init()
        }
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .opacity(0.5)
            ScrollView {
                VStack {
                    DetailView(title: "Colors", systemImage: "paintbrush") {
                        LazyVGrid(columns: [.init(.adaptive(minimum: 75, maximum: 100), spacing: 10)], spacing: 10) {
                            ForEach($meshService.colors) { color in
                                ColorView(color: color)
                                    .onAppear {
                                        print(color.point)
                                    }
                            }
                        }
                    }
                }
                .padding()
            }
        }.navigationBarHidden(true)
    }
    
    struct ColorView: View {
        @Binding var color: MeshNode.Color
        
        @State private var isPresentingPopover: Bool = false
        
        var body: some View {
            Button {
                isPresentingPopover.toggle()
            } label: {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(color.color))
                    .aspectRatio(1/1, contentMode: .fit)
                    .shadow(color: Color(color.color).opacity(0.2), radius: 10, y: 4)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $isPresentingPopover) {
                ColorPickerView(color: color.color) { color in
                    self.color.color = color
                }
            }
        }
    }
    
    struct DetailView<Content: View>: View {
        let title: String
        let systemImage: String
        let content: Content
        
        init(title: String, systemImage: String, @ViewBuilder content: @escaping () -> Content) {
            self.title = title
            self.systemImage = systemImage
            self.content = content()
        }
        
        var body: some View {
            let view = VStack {
                Label(title, systemImage: systemImage)
                    .font(.headline.bold())
                    .foregroundColor(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                content
            }
            .padding()
            
            if #available(macCatalyst 15.0, *) {
                view
                    .background(ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.background)
                            .opacity(0.3)
                            .blendMode(.overlay)
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(lineWidth: 1)
                            .fill(Color(uiColor: .separator))
                            .opacity(0.5)
                    }.compositingGroup())
            } else {
                view
                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color(.secondarySystemBackground)))
            }
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
