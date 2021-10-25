//
//  ExportView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/24/21.
//

import SwiftUI

struct ExportView: View {
    let renderImage: UIImage
    @State var image: CIImage = .black
    let dismissAction: () -> Void
    
    @State private var isExporting: Bool = false
    
    @State private var grain: Float = 0
    @State private var blur: Float = 0
    
    var body: some View {
        VStack {
            Image(uiImage: renderImage)
                .resizable()
                .aspectRatio(1/1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(radius: 30, y: 10)
                .padding()
            Text("\(Int(renderImage.size.width * renderImage.scale))x\(Int(renderImage.size.height * renderImage.scale))")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(Color.secondary)
            Divider()
            VStack {
                HStack {
                    Label("Film Grain", systemImage: "film.fill")
                    Slider(value: $grain, in: 0...100)
                    Text("\(Int(grain))%")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(Color.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                HStack {
                    Label("Blur", systemImage: "drop.fill")
                    Slider(value: $blur, in: 0...100)
                    Text("\(Int(blur))%")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(Color.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(.secondarySystemBackground)))
            Spacer()
            HStack {
                Button("Cancel", action: dismissAction)
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button("Export") {
                    UIPasteboard.general.image = renderImage
                    
                    isExporting.toggle()
                }
                .keyboardShortcut(.defaultAction)
#if targetEnvironment(macCatalyst)
                .popover(isPresented: $isExporting) {
                    ShareSheet(activityItems: [renderImage])
                        .onDisappear {
                            dismissAction()
                        }
                }
#else
                .sheet(isPresented: $isExporting) {
                    ShareSheet(activityItems: [renderImage])
                        .onDisappear {
                            dismissAction()
                        }
                }
#endif
            }
        }
        .padding()
        .onAppear {
            image = renderImage.ciImage ?? CIImage(image: renderImage) ?? .blue
        }
#if targetEnvironment(macCatalyst)
        .frame(maxWidth: 400)
#endif
    }
}
