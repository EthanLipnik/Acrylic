//
//  SettingsView+GeneralView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/6/22.
//

import SwiftUI

extension SettingsView {
    struct GeneralView: View {
        @AppStorage("colorSpace") var colorSpace: ColorSpace = .sRGB
        
        var body: some View {
            SectionView {
                Toggle(isOn: .constant(false)) {
                    Text("Launch Acrylic on system startup")
                }.disabled(true)
                
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
