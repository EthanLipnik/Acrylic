//
//  VideosManagementView+VideosView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/5/22.
//

import SwiftUI
import PixabayKit
import Sebu

extension VideosManagementView {
    struct VideosView: View {
        @StateObject var debounceObject = DebounceObject()
        @StateObject var downloadService = VideoDownloadService()
        
        @AppStorage("VWSearchItemLimit") var searchItemLimit: Int = 200
        @AppStorage("shouldEnableVWSafeSearch") var shouldEnableSafeSearch: Bool = true
        
        @State var videos: [Video] = []
        @State var shouldShowDownloadingVideos: Bool = false
        @State var sort: String = "popular"
        @State var editorsChoice: Bool = true
        @State var selectedVideo: Video?
        @State var filter4k: Bool = true
        
        @Binding var category: SearchCategory?
        private let pixabay = PixabayKit("PIXABAY_API_KEY")
        
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
                    VideosManagementView.SelectedItemView(video: selectedVideo)
                        .environmentObject(downloadService)
                        .onChange(of: selectedVideo) { newValue in
                            guard let newValue else { return }
                            downloadService.getVideoIsDownloaded(newValue)
                        }
                }.frame(width: 350)
            }
            .animation(.easeInOut, value: videos)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Toggle(isOn: $editorsChoice) {
                        Label("Editors Choice", systemImage: "bookmark.circle" + (editorsChoice ? ".fill" : ""))
                            .animation(.easeInOut(duration: 0.1), value: editorsChoice)
                    }
                    .onChange(of: editorsChoice) { _ in
                        Task(priority: .high) {
                            await search()
                        }
                    }
                    
                    Toggle(isOn: $filter4k) {
                        Label("4K Only", systemImage: "4k.tv")
                    }
                    .onChange(of: filter4k) { _ in
                        Task(priority: .high) {
                            await search()
                        }
                    }
                    
                    Button {
                        shouldShowDownloadingVideos.toggle()
                    } label: {
                        Label("Downloads",
                              systemImage: "arrow.down.circle" + ((downloadService.downloadingVideos
                                .contains(where: { $0.value != .done() })) ? ".fill" : ""))
                        .animation(.easeInOut(duration: 0.1), value: downloadService.downloadingVideos)
                    }
                    .popover(isPresented: $shouldShowDownloadingVideos) {
                        downloadsView
                    }
                    
                    Picker(selection: $sort) {
                        Text("Popular")
                            .tag("popular")
                        
                        Text("Latest")
                            .tag("latest")
                    } label: {
                        Label("Sort", systemImage: "line.2.horizontal.decrease.circle")
                    }
                    .pickerStyle(.menu)
                    .onChange(of: sort) { _ in
                        Task(priority: .high) {
                            await search()
                        }
                    }
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
                    await search()
                }
            }
            .task {
                await search()
            }
            .onChange(of: category) { _ in
                Task(priority: .high) {
                    await search()
                }
            }
        }
        
        var downloadsView: some View {
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
            }
            .frame(width: 300, height: 400)
        }
        
        func search() async {
            let category = self.category ?? .all
            do {
                let cacheName = "videos" + "-\(sort)-" + "-safeSearch \(shouldEnableSafeSearch)-" + "-limit \(searchItemLimit)-" + "-editorsChoice \(editorsChoice)-" + "-category \(category.rawValue)-" + "-width \(filter4k ? 3000 : 0)" + debounceObject.debouncedText
                if let videos: [Video] = try? Sebu.default.get(withName: cacheName) {
                    self.videos = videos
                    return
                }
                
                let videos = try await pixabay.searchVideos(debounceObject.debouncedText,
                                                            safeSearch: shouldEnableSafeSearch,
                                                            order: sort,
                                                            type: .all,
                                                            editorsChoice: editorsChoice,
                                                            category: category,
                                                            minWidth: filter4k ? 3000 : 0,
                                                            count: searchItemLimit)
                self.videos = videos
                
                try? Sebu.default.save(videos, withName: cacheName, expiration: Calendar.current.date(byAdding: .hour, value: 24, to: Date()))
            } catch {
                print(error)
            }
        }
    }
}
