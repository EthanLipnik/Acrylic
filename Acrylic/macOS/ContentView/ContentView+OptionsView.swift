//
//  ContentView+OptionsView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/8/22.
//

import SwiftUI

extension ContentView {
    struct OptionsView: View {
        @Binding var selectedWallpaper: WallpaperType?
        @EnvironmentObject var videosViewModel: VideosViewModel
        @AppStorage("currentVideoBackgroundId") var currentVideoBackgroundId: String = ""
        
        var body: some View {
            ScrollView(.horizontal) {
                LazyHStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.black
                            .opacity(0.5)
                            .blendMode(.overlay))
                        .aspectRatio(16/10, contentMode: .fit)
                        .overlay(Image(systemName: "dice.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                            .foregroundStyle(.secondary))
                        .onTapGesture {
                            switch selectedWallpaper {
                            case .fluid, .music:
                                break
                            case .video:
                                currentVideoBackgroundId = videosViewModel.videos.randomElement()?.id ?? ""
                                videosViewModel.updateWallpaper()
                            case .none:
                                break
                            }
                        }
                    
                    switch selectedWallpaper {
                    case .fluid, .music:
                        EmptyView()
                    case .video:
                        ForEach(videosViewModel.videos) { video in
                            if let image = video.thumbnail {
                                Image(nsImage: image)
                                    .resizable()
                                    .aspectRatio(16/10, contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .overlay(
                                        currentVideoBackgroundId == video.id ? RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(Color.accentColor, lineWidth: 4) : nil
                                    )
                                    .shadow(radius: 8, y: 8)
                                    .onTapGesture {
                                        currentVideoBackgroundId = video.id
                                        videosViewModel.updateWallpaper()
                                    }
                            }
                        }
                    case .none:
                        EmptyView()
                    }
                }
                .padding()
            }
            .background(
                Color.black
                    .opacity(0.5)
                    .blendMode(.overlay)
            )
            .frame(height: 100)
        }
    }
}

struct ContentView_OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView.OptionsView(selectedWallpaper: .constant(nil))
    }
}
