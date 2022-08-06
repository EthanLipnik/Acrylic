//
//  VideosManagementView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/5/22.
//

import SwiftUI
import PixabayKit
import AVKit
import Sebu

struct VideosManagementView: View {
    @State var videos: [Video] = []
    @State var shouldShowDownloadingVideos: Bool = false
    @StateObject var debounceObject = DebounceObject()
    @StateObject var downloadService = VideoDownloadService()
    
    private let pixabay = PixabayKit("29060517-dfcaf5cbb4b15b48ba5e61f22")
    
    var body: some View {
        Group {
            if #available(iOS 16.0, macOS 13.0, *) {
                NavigationSplitView {
                    SidebarView()
                } detail: {
                    VideosView(videos: videos)
                        .animation(.default, value: videos)
                        .environmentObject(downloadService)
                }
            } else {
                NavigationView {
                    SidebarView()
                    VideosView(videos: videos)
                        .animation(.default, value: videos)
                        .environmentObject(downloadService)
                }
            }
        }
        .navigationTitle("Videos")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    shouldShowDownloadingVideos.toggle()
                } label: {
                    Label("Downloads", systemImage: "arrow.down.circle")
                }
                .popover(isPresented: $shouldShowDownloadingVideos) {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            if downloadService.downloadingVideos.isEmpty {
                                Text("No downloads")
                                    .font(.title3.bold())
                                    .foregroundStyle(.secondary)
                            }
                            ForEach(downloadService.downloadingVideos.sorted(by: { $0.key.id > $1.key.id }), id: \.key) { (video, state) in
                                HStack {
                                    VideoItemView(video: video)
                                    switch state {
                                    case .downloading(let progress, _):
                                        ProgressView(value: progress, total: .init(1))
                                            .progressViewStyle(.linear)
                                    case .processing, .notStarted:
                                        ProgressView()
                                            .progressViewStyle(.linear)
                                    case .done:
                                        Spacer()
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.accentColor)
                                    case .failed(let error):
                                        Text("Failed to download. " + error.localizedDescription)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                Divider()
                            }
                        }
                        .padding()
                    }.frame(width: 300, height: 400)
                }
                
                Picker(selection: .constant("popular")) {
                    Text("Popular")
                        .tag("popular")
                    
                    Text("New")
                        .tag("new")
                } label: {
                    Label("Sort", systemImage: "line.2.horizontal.decrease.circle")
                }.pickerStyle(.menu)
            }
        }
        .searchable(text: $debounceObject.text, prompt: "Search Pixabay", suggestions: {
            Text("🔁 Looping")
                .searchCompletion("Looping")
            Text("🍃 Nature")
                .searchCompletion("Nature")
            Text("🦍 Gorilla")
                .searchCompletion("Gorilla")
        })
        .onChange(of: debounceObject.debouncedText) { text in
            Task(priority: .high) {
                await search(text)
            }
        }
        .task {
            await search()
        }
    }
    
    func search(_ search: String = "") async {
        do {
            let cacheName = "videos" + search
            if let videos: [Video] = try? Sebu.default.get(withName: cacheName) {
                self.videos = videos
                return
            }
            
            let videos = try await pixabay.searchVideos(search, count: 200)
            self.videos = videos
            
            try? Sebu.default.save(videos, withName: cacheName, expiration: Calendar.current.date(byAdding: .hour, value: 1, to: Date()))
        } catch {
            print(error)
        }
    }
}

struct VideosManagementView_Previews: PreviewProvider {
    static var previews: some View {
        VideosManagementView()
    }
}
