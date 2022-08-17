//
//  SettingsView+StartupView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/6/22.
//

import SwiftUI

extension SettingsView {
    struct StartupView: View {
        var body: some View {
            SectionView {
                Toggle(isOn: .constant(false)) {
                    Text("Launch Acrylic on system startup")
                }.disabled(true)
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
