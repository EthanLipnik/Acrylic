//
//  SettingsView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/1/22.
//

import SwiftUI

struct SettingsView: View {
    @State
    var selection: Int = 0

    var body: some View {
        TabView(selection: $selection) {
            FormView {
                GeneralView()
            }
            .fixedSize(horizontal: false, vertical: true)
            .tabItem {
                Label("General", systemImage: "gearshape.fill")
            }
            .tag(0)

            FormView {
                FluidWallpaperView()
            }
            .frame(height: 600)
            .tabItem {
                Label("Fluid", systemImage: "square.stack.3d.down.right.fill")
            }
            .tag(1)

            FormView {
                VideoWallpaperView()
            }
            .fixedSize(horizontal: false, vertical: true)
            .tabItem {
                Label("Video", systemImage: "play.rectangle.fill")
            }
            .tag(2)
        }
    }

    struct FormView<Content: View>: View {
        @ViewBuilder
        let content: () -> Content

        var body: some View {
            Group {
                Form {
                    content()
                }
                .formStyle(.grouped)
            }
        }
    }

    struct SectionView<Content: View, Header: View>: View {
        let contentView: Content
        let headerView: Header
        let footerView: AnyView?

        init(@ViewBuilder content: () -> Content, @ViewBuilder header: () -> Header) {
            contentView = content()
            headerView = header()
            footerView = nil
        }

        init(
            @ViewBuilder content: () -> Content,
            @ViewBuilder header: () -> Header,
            @ViewBuilder footer: () -> some View
        ) {
            contentView = content()
            headerView = header()
            footerView = AnyView(footer())
        }

        var body: some View {
            Group {
                if let footerView {
                    Section {
                        contentView
                    } header: {
                        headerView
                    } footer: {
                        footerView
                    }
                } else {
                    Section {
                        contentView
                    } header: {
                        headerView
                    }
                }
            }
        }
    }
}

struct MacSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
