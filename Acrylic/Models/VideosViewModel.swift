//
//  VideoViewModel.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/8/22.
//

import Foundation
import AppKit
import AVKit

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
            
            videos = try FileManager.default.contentsOfDirectory(atPath: folder.path)
                .map({ folder.appendingPathComponent($0) })
                .filter({ $0.pathExtension == "mp4" })
                .compactMap({ [weak self] video in
                    guard let videoId = video.deletingPathExtension().lastPathComponent.components(separatedBy: "Video ").last,
                          video.lastPathComponent.hasPrefix("Video ") else { return nil }
                    return VideoItem(fileUrl: video,
                                     id: videoId,
                                     thumbnail: self?.generateThumbnail(video))
                })
        } catch {
            print(error)
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
    
    private func generateThumbnail(_ url: URL) -> NSImage? {
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
            return nil
        }
        
        return NSImage(cgImage: thumbnailImageRef, size: NSSize(width: 640, height: 480))
    }
}
