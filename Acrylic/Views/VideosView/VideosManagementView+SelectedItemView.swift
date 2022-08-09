//
//  VideosManagementView+SelectedItemView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/6/22.
//

#if os(macOS)
import PixabayKit
import SwiftUI

extension VideosManagementView {
    struct SelectedItemView: View {
        @EnvironmentObject var downloadService: VideoDownloadService
        @AppStorage("currentVideoBackgroundId") var currentVideoBackgroundId: String = ""
        
        let video: Video?
        
        var body: some View {
            let state = downloadService.downloadingVideos.first(where: { $0.key.id == video?.id })?.value ?? (downloadService.getVideoIsDownloaded(video) ? .done() : nil)
            
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
                .shadow(radius: 8, y: 4)
                
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
                        Divider()
                        Label("\(video?.duration ?? 0)s", systemImage: "timer")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Label("1920x1080", systemImage: "rectangle.dashed")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .redacted(reason: .placeholder)
                        Divider()
                        Label("50mb", systemImage: "doc")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .redacted(reason: .placeholder)
                        Divider()
                        Label("30s", systemImage: "timer")
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
                            Button {
                                do {
                                    guard let video else { return }
                                    try downloadService.delete(video)
                                } catch {
                                    print(error)
                                }
                            } label: {
                                Image(systemName: "trash")
                            }.disabled(video == nil)
                        case .failed(let error):
                            Text("Failed to download. " + error.localizedDescription)
                        }
                    }
                    
                    Spacer()
                    Button {
                        if let id = video?.id {
                            currentVideoBackgroundId = "\(id)"
                            
                            Task {
                                do {
                                    try await WallpaperService.shared.start(.video)
                                    
                                    NotificationCenter.default.post(name: .init("didEnableVideoBackground"), object: nil)
                                } catch {
                                    print(error)
                                }
                            }
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
#endif
