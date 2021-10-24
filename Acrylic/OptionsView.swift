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
        VStack(spacing: 0) {
            Divider()
                .opacity(0.5)
            scrollView
        }
        .navigationBarHidden(true)
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
                DetailView(title: "Detail", systemImage: "sparkles") {
                    HStack {
                        Label("Subdivsions", systemImage: "rectangle.split.3x3.fill")
                        Slider(value: subdivsionsIntProxy, in: 4.0...36.0, step: 2.0)
                        Text("\(meshService.subdivsions)")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(Color.secondary)
                    }
                    .animation(.spring(), value: meshService.subdivsions)
                    .contextMenu {
                        Button("Reset") {
                            withAnimation {
                                meshService.subdivsions = 18
                            }
                        }
                    }
                    
                    HStack {
                        Label("Scale Factor", systemImage: "arrow.up.left.and.arrow.down.right")
                        Slider(value: $meshService.contentScaleFactor, in: 1.0...50.0)
                        Text(String(format: "%.1f", meshService.contentScaleFactor))
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(Color.secondary)
                    }
                    .animation(.spring(), value: meshService.contentScaleFactor)
                    .contextMenu {
                        Button("Reset") {
                            withAnimation {
                                meshService.contentScaleFactor = 1
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    var colorsView: some View {
        DetailView(title: "Colors", systemImage: "paintbrush") {
            VStack(spacing: 20) {
                LazyVGrid(columns: [.init(.adaptive(minimum: 75, maximum: 100), spacing: 10)], spacing: 10) {
                    ForEach($meshService.colors) { color in
                        ColorView(color: color)
                    }
                }
                .rotationEffect(.degrees(-90))
                HStack {
                    Button("Clear", action: clearColors)
                    Spacer()
                    Button("Randomize", action: randomizeColors)
                }
            }
        }
        .contextMenu {
            Menu("Paste Colors") {
                Button("RGB") {
                    guard let copiedColors = UIPasteboard.general.string else { return }
                    let rgbList = copiedColors
                        .replacingOccurrences(of: ",", with: "")
                        .replacingOccurrences(of: "rgb(", with: "")
                        .replacingOccurrences(of: ")", with: "")
                        .split(separator: "\n")
                        .map({ $0
                            .components(separatedBy: .whitespaces)
                            .compactMap({ Int($0) })
                            .map({ CGFloat($0) / 255 }) })
                    
                    for i in 0..<rgbList.count {
                        if meshService.colors.count > i {
                            let rgb = rgbList[i]
                            DispatchQueue.main.async {
                                withAnimation {
                                    meshService.colors[i].color = UIColor(red: rgb[0], green: rgb[1], blue: rgb[2], alpha: 1)
                                }
                            }
                        }
                    }
                }
            }
        }
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
                    .shadow(color: Color(color.color).opacity(0.4), radius: 10, y: 4)
                    .rotationEffect(.degrees(90))
            }
            .buttonStyle(.plain)
            .hoverEffect()
            .popover(isPresented: $isPresentingPopover) {
                ColorPickerView(color: color.color) { color in
                    self.color.color = color
                }
            }
            .onDrop(of: [UTType.data.identifier], isTargeted: nil) { providers, location in
                guard let provider = providers.first else { return false }
                if provider.hasItemConformingToTypeIdentifier("com.apple.uikit.color") {
                    provider.loadObject(ofClass: UIColor.self) { reading, error in
                        DispatchQueue.main.async {
                            color.color = reading as! UIColor
                        }
                    }
                }
                return true
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
            
            let defaultView = view
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(.tertiarySystemBackground)))
            
            if #available(macCatalyst 15.0, *) {
#if targetEnvironment(macCatalyst)
                view
                    .background(ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.background)
                            .opacity(0.2)
                            .blendMode(.overlay)
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(lineWidth: 1)
                            .fill(Color(uiColor: .separator))
                            .opacity(0.5)
                    }.compositingGroup())
#else
                defaultView
#endif
            } else {
                defaultView
                    .toolbar {}
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
