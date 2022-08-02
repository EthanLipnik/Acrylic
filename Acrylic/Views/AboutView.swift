//
//  AboutView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/2/22.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            Image("Icon")
                .resizable()
                .aspectRatio(1/1, contentMode: .fit)
                .frame(maxWidth: 100)
            Text("Acrylic")
                .font(.largeTitle)
                .bold()
            LinksView()
            CreditsView()
            Spacer()
        }
        .padding()
        .background(VisualEffectView(material: .popover, blendingMode: .behindWindow).edgesIgnoringSafeArea(.all))
    }
    
    struct LinksView: View {
        @Environment(\.openURL) var openUrl
        
        var body: some View {
            GroupBox {
                if let url = URL(string: "https://ethanlipnik.com/acrylic") {
                    Link(destination: url) {
                        Label("Website", systemImage: "globe")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                if let url = URL(string: "https://github.com/EthanLipnik/MeshKit") {
                    Link(destination: url) {
                        Label("MeshKit", systemImage: "circle.grid.cross")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                if let url = URL(string: "https://github.com/Nekitosss/MeshGradient") {
                    Link(destination: url) {
                        Label("MeshGradient", systemImage: "square.stack.3d.forward.dottedline")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } label: {
                Label("Links", systemImage: "link")
            }
        }
    }
    
    struct CreditsView: View {
        @Environment(\.openURL) var openUrl
        
        var body: some View {
            GroupBox {
                userView("Ethan Lipnik",
                         username: "EthanLipnik",
                         profilePic: URL(string: "https://pbs.twimg.com/profile_images/1484616636866904066/38t7SErv_400x400.jpg"),
                         body: "Developer and Designer")
                
                Divider()
                
                userView("Nikita Patskov",
                         username: "NikitkaPa",
                         profilePic: URL(string: "https://pbs.twimg.com/profile_images/1258140999672459264/QWDsekY0_400x400.jpg"),
                         body: "MeshGradient Library")
            } label: {
                Label("Credits", systemImage: "person.crop.square.filled.and.at.rectangle")
            }
        }
        
        @ViewBuilder
        func userView(_ name: String, username: String, profilePic: URL?, body: String) -> some View {
            Button {
                if let url = URL(string: "https://twitter.com/" + username) {
                    openUrl(url)
                }
            } label: {
                HStack {
                    Group {
                        if #available(iOS 15.0, macOS 12.0, *) {
                            AsyncImage(url: profilePic) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                case .failure:
                                    Color.red
                                case .empty:
                                    Color.secondary
                                @unknown default:
                                    Color.secondary
                                }
                            }
                            .aspectRatio(1/1, contentMode: .fit)
                        } else {
                            Image(systemName: "person.circle.fill")
                        }
                    }
                    .frame(height: 45)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(name)
                                .font(.headline)
                            Text("@" + username)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.secondary)
                                .font(.callout)
                        }
                        Text(body)
                    }
                }
            }.buttonStyle(.plain)
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .frame(width: 500, height: 400)
    }
}

#if canImport(AppKit)
import AppKit
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .followsWindowActiveState
        return visualEffectView
    }
    
    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}
#endif
