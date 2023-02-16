//
//  ContentView+OptionsView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/8/22.
//

import MeshKit
import SwiftUI

extension ContentView {
    struct OptionsView: View {
        @Binding var selectedWallpaper: WallpaperType?
        @EnvironmentObject var wallpaperService: WallpaperService
        @StateObject var videosViewModel = VideosViewModel()
        @AppStorage("currentVideoBackgroundId") var currentVideoBackgroundId: String = ""

        @State private var isHoldingRandomizeButton: Bool = false
        @State private var selectedHue: Hue?

        let popoverNotification = NotificationCenter.default
            .publisher(for: NSNotification.Name("didOpenStatusBarItem"))

        var body: some View {
            ScrollView(.horizontal) {
                LazyHStack {
                    randomizeButton

                    switch selectedWallpaper {
                    case .fluid, .nowPlaying:
                        EmptyView()
                    case .video:
                        ForEach(videosViewModel.videos) { video in
                            if let image = video.thumbnail {
                                Image(nsImage: image)
                                    .resizable()
                                    .aspectRatio(16 / 10, contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .overlay(
                                        currentVideoBackgroundId == video.id ? RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(Color.accentColor, lineWidth: 4) : nil
                                    )
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            withAnimation {
                                                try? videosViewModel.delete(video)

                                                if currentVideoBackgroundId == video.id {
                                                    currentVideoBackgroundId = videosViewModel.videos.first?.id ?? ""
                                                    videosViewModel.updateWallpaper()
                                                }
                                            }
                                        } label: {
                                            Label("Move to Trash", systemImage: "trash")
                                        }
                                    }
                                    .shadow(radius: 8, y: 8)
                                    .onTapGesture {
                                        guard !wallpaperService.isLoading else { return }

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
            .onReceive(popoverNotification) { _ in
                Task(priority: .userInitiated) {
                    do {
                        try await videosViewModel.getVideos()
                    } catch {
                        print(error)
                    }
                }
            }
        }

        var randomizeButton: some View {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.black
                    .opacity(0.5)
                    .blendMode(.overlay))
                .aspectRatio(16 / 10, contentMode: .fit)
                .overlay(Image(systemName: "dice.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .foregroundStyle(.secondary))
                .scaleEffect(isHoldingRandomizeButton ? 0.9 : 1)
                .animation(.spring(), value: isHoldingRandomizeButton)
                .onTapGesture {
                    isHoldingRandomizeButton = false
                    guard !wallpaperService.isLoading else { return }

                    switch selectedWallpaper {
                    case .fluid, .nowPlaying:
                        getFluidWindow()?.viewModel?.newPalette()
                    case .video:
                        currentVideoBackgroundId = videosViewModel.videos.randomElement()?.id ?? ""
                        videosViewModel.updateWallpaper()
                    case .none:
                        break
                    }
                }
                .onLongPressGesture(perform: {
                    isHoldingRandomizeButton = true
                }, onPressingChanged: { bool in
                    isHoldingRandomizeButton = bool
                })
        }

        func getFluidWindow() -> FluidWindow? {
            return NSApp.windows.compactMap { $0 as? FluidWindow }.first
        }
    }
}

struct ContentView_OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView.OptionsView(selectedWallpaper: .constant(nil))
    }
}
