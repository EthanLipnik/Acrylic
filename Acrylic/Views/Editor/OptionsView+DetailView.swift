//
//  OptionsView+DetailView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/24/21.
//

import SwiftUI

extension OptionsView {
    struct DetailView<Content: View>: View {
        let title: String
        let systemImage: String
        let withBackground: Bool
        let forceMacStyle: Bool
        let info: String?
        let content: Content

        @State private var isShowingInfo: Bool

        init(title: String, systemImage: String, withBackground: Bool = true, forceMacStyle: Bool = false, info: String? = nil, @ViewBuilder content: @escaping () -> Content) {
            self.title = title
            self.systemImage = systemImage
            self.content = content()
            self.withBackground = withBackground
            self.forceMacStyle = forceMacStyle
            self.info = info

            self._isShowingInfo = .init(initialValue: false)
        }

        var body: some View {
            let view = view
                .padding()

            Group {
                if UIDevice.current.userInterfaceIdiom == .mac || forceMacStyle {
                    view
                        .background(withBackground ? ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(.systemBackground))
                                .opacity(0.2)
                                .blendMode(.overlay)
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(lineWidth: 1)
                                .fill(Color(.separator))
                                .opacity(0.5)
                        }.compositingGroup() : nil)
                } else {
                    view
                        .background(withBackground ? RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(.tertiarySystemBackground)) : nil)
                }
            }
            .alert(isPresented: $isShowingInfo) {
                Alert(title: Text(title + " Info"), message: Text(info ?? ""), dismissButton: .cancel(Text("Ok")))
            }
        }

        var view: some View {
            VStack {
                HStack {
                    if #available(iOS 15.0, macCatalyst 15.0, *) {
                        Label(title, systemImage: systemImage)
                            .font(.headline.bold())
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Label(title, systemImage: systemImage)
                            .font(.headline.bold())
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if info != nil {
                        Button {
                            isShowingInfo.toggle()
                        } label: {
                            Image(systemName: "info.circle")
                        }
                    }
                }
                Divider()
                content
            }
        }
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
