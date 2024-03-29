//
//  SettingsView+GeneralView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/6/22.
//

import ServiceManagement
import SwiftUI

extension SettingsView {
    struct GeneralView: View {
        @AppStorage("colorSpace")
        var colorSpace: ColorSpace = .sRGB
        @AppStorage("launchAtLogin")
        var launchAtLogin: Bool = false

        var body: some View {
            SectionView {
                Toggle(isOn: $launchAtLogin) {
                    Text("Launch Acrylic on system startup")
                }
                .onChange(of: launchAtLogin) { newValue in
                    do {
                        let item = SMAppService.mainApp
                        if newValue {
                            try item.register()
                        } else {
                            try item.unregister()
                        }
                    } catch {
                        print(error)
                    }
                }
                .onAppear {
                    launchAtLogin = SMAppService.mainApp.status == .enabled
                }

                Picker("Color Space", selection: $colorSpace) {
                    ForEach(ColorSpace.allCases, id: \.rawValue) { colorSpace in
                        Text(colorSpace.displayName)
                            .tag(colorSpace)
                    }
                }
            } header: {
                Label {
                    Text("General")
                } icon: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

struct SettingsView_StartupView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView.GeneralView()
    }
}
