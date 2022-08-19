//
//  OnboardingView+VideoView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/10/22.
//

import SwiftUI

extension OnboardingView {
    struct VideoView: View {
        @Environment(\.colorScheme) var colorScheme
        @Binding var page: Int
        let closeWindow: () -> Void

        var body: some View {
            VStack(spacing: 30) {
                Image("VideoThumbnail")
                    .resizable()
                    .frame(width: 300)
                    .aspectRatio(16/10, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .shadow(radius: 15, y: 8)
                Text("Video Wallpaper")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)

                GroupBox {
                    Text("Reanimate your desktop with a selection of hundreds of high quality videos. Find the right one for your mood.")
                        .frame(maxWidth: 350)
                        .padding()
                }
                Spacer()

                Button("Launch Acrylic in the Menu Bar", action: closeWindow)
                .controlSize(.large)
                .buttonBorderShape(.roundedRectangle)
                .buttonStyle(.borderedProminent)
            }
            .padding(30)
        }
    }
}

struct OnboardingView_VideoView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView.VideoView(page: .constant(2)) {}
    }
}
