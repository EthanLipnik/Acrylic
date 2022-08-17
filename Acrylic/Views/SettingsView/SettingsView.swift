//
//  SettingsView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/1/22.
//

import SwiftUI

struct SettingsView: View {
    @State var selection: Int = 0
    
    var body: some View {
        TabView(selection: $selection) {
            FormView {
                StartupView()
            }
            .frame(height: 100)
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
            .frame(height: 300)
            .tabItem {
                Label("Video", systemImage: "play.rectangle.fill")
            }
            .tag(2)
        }
    }
    
    struct FormView<Content: View>: View {
        @ViewBuilder let content: () -> Content
        
        var body: some View {
            Group {
                if #available(iOS 14.0, macOS 13.0, *) {
                    Form {
                        content()
                    }.groupedForm()
                } else {
                    ScrollView {
                        content()
                    }
                }
            }
        }
    }

    struct SectionView<Content: View, Header: View>: View {
        let contentView: Content
        let headerView: Header
        let footerView: AnyView?

        init(@ViewBuilder content: () -> Content, @ViewBuilder header: () -> Header) {
            self.contentView = content()
            self.headerView = header()
            self.footerView = nil
        }

        init<Footer: View>(@ViewBuilder content: () -> Content, @ViewBuilder header: () -> Header, @ViewBuilder footer: () -> Footer) {
            self.contentView = content()
            self.headerView = header()
            self.footerView = AnyView(footer())
        }

        var body: some View {
            Group {
                if #available(iOS 16.0, macOS 13.0, *) {
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
                } else {
                    GroupBox {
                        contentView
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if let footerView {
                            footerView
                        }
                    } label: {
                        headerView
                    }
                    .padding()
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

extension View {
    @ViewBuilder
    func groupedForm() -> some View {
        self.modifier(GroupedFormViewModifier())
    }
}

struct GroupedFormViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, macOS 13.0, *) {
            content.formStyle(.grouped)
        } else {
            content
        }
    }
}
