//
//  VideoViewModel.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/8/22.
//

import Foundation
import AppKit
import AVKit
import SwiftUI

@MainActor
class VideosViewModel: ObservableObject {
    @Published var videos: [VideoItem] = []
    
    let folder: URL
    
    struct VideoItem: Identifiable, Hashable {
        var fileUrl: URL
        var id: String
        
        var thumbnail: NSImage? = nil
    }
    
    init() {
        let documentsFolder = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask)[0]
        let acrylicFolder = documentsFolder.appendingPathComponent("Acrylic")
        folder = acrylicFolder.appendingPathComponent("Videos")
        
        do {
            if !FileManager.default.fileExists(atPath: acrylicFolder.path) {
                try FileManager.default.createDirectory(at: acrylicFolder, withIntermediateDirectories: true)
            }
            
            if !FileManager.default.fileExists(atPath: folder.path) {
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            }
            
            Task(priority: .userInitiated) { [weak self] in
                do {
                    try await self?.getVideos()
                } catch {
                    print(error)
                }
            }
        } catch {
            print(error)
        }
    }
    
    func getVideos() async throws {
        let contents = try FileManager.default.contentsOfDirectory(atPath: folder.path)
            .map({ folder.appendingPathComponent($0) })
            .filter({ $0.pathExtension == "mp4" && $0.lastPathComponent.hasPrefix("Video ") })
            .compactMap({ url -> (URL, String)? in
                guard let id = url.deletingPathExtension().lastPathComponent.components(separatedBy: "Video ").last else { return nil }
                return (url, id)
            })
        
        let videos = try await contents
            .concurrentMap({ [weak self] video in
                let thumbnail = try await self?.generateThumbnail(video.0)
                return VideoItem(fileUrl: video.0,
                                 id: video.1,
                                 thumbnail: thumbnail)
            })
        
        withAnimation { [weak self] in
            self?.videos = videos
        }
    }
    
    @MainActor
    func delete(_ video: VideoItem ) throws {
        if let index = videos.firstIndex(of: video) {
            videos.remove(at: index)
        }
        
        try FileManager.default.trashItem(at: video.fileUrl, resultingItemURL: nil)
    }
    
    func updateWallpaper() {
        Task {
            do {
                try await WallpaperService.shared.start(.video)
            } catch {
                print(error)
            }
        }
    }
    
    private func generateThumbnail(_ url: URL) async throws -> NSImage? {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let asset = AVURLAsset(url: url)
                
                let assetIG = AVAssetImageGenerator(asset: asset)
                assetIG.appliesPreferredTrackTransform = true
                assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
                
                let cmTime = CMTime(seconds: 2, preferredTimescale: 60)
                let thumbnailImageRef: CGImage
                do {
                    thumbnailImageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
                } catch let error {
                    print("Error: \(error)")
                    continuation.resume(throwing: error)
                    return
                }
                
                continuation.resume(returning: NSImage(cgImage: thumbnailImageRef, size: NSSize(width: 640, height: 480)))
            }
        }
    }
}

extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
    
    func concurrentMap<T>(
        _ transform: @escaping (Element) async throws -> T
    ) async throws -> [T] {
        let tasks = map { element in
            Task {
    try await transform(element)
}
        }

        return try await tasks.asyncMap { task in
            try await task.value
        }
    }
}
