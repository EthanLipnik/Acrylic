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
        let content: Content
        
        init(title: String, systemImage: String, withBackground: Bool = true, @ViewBuilder content: @escaping () -> Content) {
            self.title = title
            self.systemImage = systemImage
            self.content = content()
            self.withBackground = withBackground
        }
        
        var body: some View {
            let view = view
                .padding()
            
#if targetEnvironment(macCatalyst)
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
#else
            view
                .background(withBackground ? RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(.tertiarySystemBackground)) : nil)
#endif
        }
        
        var view: some View {
            VStack {
                Label(title, systemImage: systemImage)
                    .font(.headline.bold())
                    .foregroundColor(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                content
            }
        }
    }
}
