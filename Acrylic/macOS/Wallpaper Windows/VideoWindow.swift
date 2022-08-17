//
//  VideoWindow.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/4/22.
//

import AppKit
import AVKit
import PixabayKit

class VideoWindow: WallpaperWindow {
    override var wallpaperType: WallpaperType? { return .fluid }

    private lazy var videoFile: URL? = {
        guard let currentVideoBackgroundId = UserDefaults.standard.string(forKey: "currentVideoBackgroundId") else { return nil }

        let documentsFolder = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask)[0]
        let acrylicFolder = documentsFolder.appendingPathComponent("Acrylic")
        let folder = acrylicFolder.appendingPathComponent("Videos")

        return folder.appendingPathComponent("Video " + currentVideoBackgroundId + ".mp4")
    }()
    private lazy var playerItem: AVPlayerItem? = {
        guard let videoFile else { return nil }

        let asset = AVURLAsset(url: videoFile)
        let playerItem = AVPlayerItem(asset: asset)

        return playerItem
    }()
    private lazy var player: AVQueuePlayer = {
        let player = AVQueuePlayer(playerItem: playerItem)

        player.automaticallyWaitsToMinimizeStalling = true
        player.volume = 0

        return player
    }()
    private lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = contentView?.bounds ?? .zero
        return playerLayer
    }()
    private var playerLooper: AVPlayerLooper!

    override init() {
        super.init()

        contentView?.layer = playerLayer
        player.play()

        if let playerItem {
            playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        }

        if let videoFile {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let screen = NSScreen.main,
                      let image = self?.imageFromVideo(url: videoFile, at: 2) else { return }
                let backgroundUrl = FileManager.default.temporaryDirectory.appendingPathComponent("\(videoFile.deletingPathExtension().lastPathComponent).png")
                do {
                    try image.pngWrite(to: backgroundUrl)

                    let workspace = NSWorkspace.shared
                    try workspace.setDesktopImageURL(backgroundUrl, for: screen)
                } catch {
                    print(error)
                }
            }
        }
    }

    func imageFromVideo(url: URL, at time: TimeInterval) -> NSImage? {
        let asset = AVURLAsset(url: url)

        let assetIG = AVAssetImageGenerator(asset: asset)
        assetIG.appliesPreferredTrackTransform = true
        assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels

        let cmTime = CMTime(seconds: time, preferredTimescale: 60)
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
