//
//  SettingsView+StartupView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/6/22.
//

import SwiftUI

#if os(macOS)
import LaunchAtLogin

extension SettingsView {
    struct StartupView: View {
        var body: some View {
            SectionView {
                LaunchAtLogin.Toggle {
                    Text("Launch Acrylic on system startup")
                }
            } header: {
                Label {
                    Text("Startup")
                } icon: {
                    Image(systemName: "power.circle.fill")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

struct SettingsView_StartupView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView.StartupView()
    }
}
#endif
