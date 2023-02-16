//
//  OnboardingView+FluidView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/10/22.
//

import MeshKit
import SwiftUI

extension OnboardingView {
    struct FluidView: View {
        @Environment(\.colorScheme) var colorScheme
        @Binding var page: Int

        var body: some View {
            let mesh: (MeshColorGrid, MeshRandomizer) = {
                let luminosity: Luminosity = {
                    switch colorScheme {
                    case .light:
                        return .light
                    case .dark:
                        return .dark
                    @unknown default:
                        return .bright
                    }
                }()
                let colors = MeshKit.generate(palette: .blue, luminosity: luminosity, withRandomizedLocations: true)
                return (colors, .withMeshColors(colors))
            }()

            return VStack(spacing: 30) {
                Mesh(colors: mesh.0,
                     animatorConfiguration: .init(animationSpeedRange: 1 ... 2, meshRandomizer: mesh.1),
                     grainAlpha: MeshDefaults.grainAlpha / 2)
                    .frame(width: 300)
                    .aspectRatio(16 / 10, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .shadow(radius: 15, y: 8)
                Text("Fluid Wallpaper")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)

                GroupBox {
                    Text("Bring your desktop to life with **Fluid Wallpaper**. Life mesh gradients smoothly animate between points and colors based on your settings.")
                        .frame(maxWidth: 350)
                        .padding()
                }
                Spacer()

                Button("Next") {
                    withAnimation(.spring()) {
                        page += 1
                    }
                }
                .controlSize(.large)
                .buttonBorderShape(.roundedRectangle)
                .buttonStyle(.borderedProminent)
            }
            .padding(30)
        }
    }
}

struct OnboardingView_FluidView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView.FluidView(page: .constant(1))
    }
}
