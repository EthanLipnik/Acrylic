//
//  VideosManagementView+VideosView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/5/22.
//

import SwiftUI
import PixabayKit

extension VideosManagementView {
    struct VideosView: View {
        @EnvironmentObject var downloadService: VideoDownloadService
        @State private var selectedVideo: Video?
        
        let videos: [Video]
        
        var body: some View {
            HStack(spacing: 0) {
                ScrollView {
                    LazyVGrid(columns: [.init(.adaptive(minimum: 150, maximum: 250))]) {
                        ForEach(videos) { video in
                            Button {
                                selectedVideo = video
                            } label: {
                                VideoItemView(video: video)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                .background(Color("Background"))
                .frame(maxWidth: .infinity)
                
                HStack {
                    Divider()
                    SelectedVideoView(video: selectedVideo)
                        .onChange(of: selectedVideo) { newValue in
                            guard let newValue else { return }
                            downloadService.getVideoIsDownloaded(newValue)
                        }
                }.frame(width: 350)
            }
        }
        
        struct SelectedVideoView: View {
            @EnvironmentObject var downloadService: VideoDownloadService
            @AppStorage("currentVideoBackgroundId") var currentVideoBackgroundId: String = ""
            
            let video: Video?
            
            var body: some View {
                let state = downloadService.downloadingVideos.first(where: { $0.key.id == video?.id })?.value
                
                VStack {
                    Group {
                        if let video {
                            VideosManagementView.VideoItemView(video: video)
                        } else {
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(.secondary)
                                .aspectRatio(16/9, contentMode: .fit)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    
                    GroupBox {
                        if let user = video?.user {
                            Label(user.name, systemImage: "person")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Label("User", systemImage: "person")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .redacted(reason: .placeholder)
                        }
                        
                        Divider()
                        
                        if let item = video?.items[.large] {
                            Label("\(item.width) x \(item.height)", systemImage: "rectangle.dashed")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Divider()
                            Label(ByteCountFormatter().string(for: item.size) ?? "\(item.size)b", systemImage: "doc")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Label("1920x1080", systemImage: "rectangle.dashed")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .redacted(reason: .placeholder)
                            Divider()
                            Label("50mb", systemImage: "doc")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .redacted(reason: .placeholder)
                        }
                        
                        Divider()
                        
                        if let video {
                            Label("\(video.views)", systemImage: "eye")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Divider()
                            Label("\(video.downloads)", systemImage: "arrow.down.circle")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Divider()
                            Label("\(video.comments)", systemImage: "bubble.left")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Label("100", systemImage: "eye")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .redacted(reason: .placeholder)
                            Divider()
                            Label("10,000", systemImage: "arrow.down.circle")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .redacted(reason: .placeholder)
                            Divider()
                            Label("20", systemImage: "bubble.left")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .redacted(reason: .placeholder)
                        }
                    }
                    Spacer()
                    
                    HStack {
                        Button {
                            guard let video else { return }
                            
                            Task(priority: .userInitiated) {
                                do {
                                    print("Downloading video")
                                    try await downloadService.download(video)
                                } catch {
                                    print(error)
                                }
                            }
                        } label: {
                            Text("Download")
                        }
                        .disabled(state != nil)
                        
                        if let state {
                            switch state {
                            case .downloading(let progress, _):
                                ProgressView(value: progress, total: .init(1))
                                    .progressViewStyle(.linear)
                            case .processing, .notStarted:
                                ProgressView()
                                    .progressViewStyle(.linear)
                            case .done:
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            case .failed(let error):
                                Text("Failed to download. " + error.localizedDescription)
                            }
                        }
                        
                        Spacer()
                        Button {
                            if let id = video?.id {
                                currentVideoBackgroundId = "\(id)"
                                
                                if WallpaperService.shared.isUsingWallpaper {
                                    WallpaperService.shared.toggle(.video)
                                }
                                
                                WallpaperService.shared.toggle(.video)
                                
                                NotificationCenter.default.post(name: .init("didEnableVideoBackground"), object: nil)
                            }
                        } label: {
                            Text("Set as Wallpaper")
                        }
                        .keyboardShortcut(.return)
                        .disabled(state != .done() || currentVideoBackgroundId == "\(video?.id ?? 0)")
                    }.disabled(video == nil)
                }
                .padding()
            }
        }
    }
}
