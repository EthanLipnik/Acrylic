//
//  VideoDownloadService.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/5/22.
//

import AVKit
import Foundation
import PixabayKit

final class VideoDownloadService: ObservableObject {
    @Published var downloadingVideos: [Video: State] = [:]

    enum State: Equatable {
        case notStarted(URL? = nil)
        case downloading(Double, URL)
        case processing
        case done(URL? = nil)
        case failed(Error)

        static func == (lhs: VideoDownloadService.State, rhs: VideoDownloadService.State) -> Bool {
            switch (lhs, rhs) {
            case (.notStarted, .notStarted):
                return true
            case (.downloading, .downloading):
                return true
            case (.processing, .processing):
                return true
            case (.done, .done):
                return true
            case (.failed, .failed):
                return true

            default:
                return false
            }
        }
    }

    let folder: URL

    init() {
        let documentsFolder = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask)[0]
        let acrylicFolder = documentsFolder.appendingPathComponent("Acrylic")
        folder = acrylicFolder.appendingPathComponent("Videos")

        if !FileManager.default.fileExists(atPath: acrylicFolder.path) {
            try? FileManager.default.createDirectory(at: acrylicFolder, withIntermediateDirectories: true)
        }

        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
    }

    @discardableResult
    func getVideoIsDownloaded(_ video: Video?) -> Bool {
        guard let video, !downloadingVideos.contains(where: { $0.key.id == video.id }) else { return false }

        let file = folder.appendingPathComponent("Video \(video.id).mp4")
        let exists = FileManager.default.fileExists(atPath: file.path)

//        if exists {
//            downloadingVideos[video] = .done(file)
//        }
        return exists
    }

    func delete(_ video: Video) throws {
        downloadingVideos.removeValue(forKey: video)
        try FileManager.default.trashItem(at: folder.appendingPathComponent("Video \(video.id).mp4"), resultingItemURL: nil)
    }

    func download(_ video: Video) async throws {
        guard let url = video.items[.large]?.url else { throw URLError(.badURL) }

        func updateState(_ state: State) {
            DispatchQueue.main.async { [weak self] in
                self?.downloadingVideos[video] = state
            }
        }

        updateState(.notStarted(url))

        do {
            var downloadRequest = URLRequest(url: url)
            downloadRequest.cachePolicy = .reloadIgnoringCacheData

            var fastRunningProgress: Double = 0
            let (asyncBytes, urlResponse) = try await URLSession.shared.bytes(for: downloadRequest)
            let length = (urlResponse.expectedContentLength)
            var data = Data()
            data.reserveCapacity(Int(length))

            for try await byte in asyncBytes {
                data.append(byte)
                let progress = Double(data.count) / Double(length)

                if Int(fastRunningProgress * 100) != Int(progress * 100) {
                    updateState(.downloading(progress, url))
                    fastRunningProgress = progress
                }
            }

            let videoFile = FileManager.default.temporaryDirectory.appendingPathComponent("video-download-\(video.id).mp4")
            let destinationUrl = folder.appendingPathComponent("\(video.id).mp4")

            if FileManager.default.fileExists(atPath: videoFile.path) {
                try FileManager.default.removeItem(at: videoFile)
            }

            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                try FileManager.default.removeItem(at: destinationUrl)
            }

            try data.write(to: videoFile)
            print("Downloaded video", videoFile.path)

            updateState(.processing)

            let convertedFile: URL
            if !UserDefaults.standard.bool(forKey: "shouldEnableVWCompression") {
                convertedFile = videoFile
            } else {
                do {
                    convertedFile = try await convert(videoFile)
                    print("Converted video", convertedFile.path)
                } catch {
                    print(error)
                    convertedFile = videoFile
                }
            }

            try FileManager.default.moveItem(at: convertedFile, to: destinationUrl)

            // Clean up
            try? FileManager.default.removeItem(at: convertedFile)
            try? FileManager.default.removeItem(at: videoFile)

            updateState(.done(destinationUrl))
        } catch {
            updateState(.failed(error))
            throw error
        }
    }

    private func convert(_ url: URL) async throws -> URL {
        let asset = AVURLAsset(url: url)

        let outputUrl = FileManager.default.temporaryDirectory.appendingPathComponent("output-\(Int(Date().timeIntervalSinceReferenceDate))-\(UUID().uuidString).mp4")

        let preset = AVAssetExportPresetHEVCHighestQuality
        let outFileType = AVFileType.m4v

        let isCompatible = await withCheckedContinuation { continuation in
            AVAssetExportSession.determineCompatibility(ofExportPreset: preset, with: asset, outputFileType: outFileType) { bool in
                continuation.resume(returning: bool)
            }
        }

        guard isCompatible else { return url }

        guard let exporter = AVAssetExportSession(asset: asset, presetName: preset) else {
            print("Unable to create AVAssetExportSession...")

            throw AVError(.sessionNotRunning)
        }

        exporter.shouldOptimizeForNetworkUse = true
        exporter.canPerformMultiplePassesOverSourceMediaData = true
        exporter.outputFileType = outFileType
        exporter.outputURL = outputUrl

        if let track = asset.tracks(withMediaType: AVMediaType.video).first {
            let bps = track.estimatedDataRate

            let duration = asset.duration.seconds

            let fileSize = Double(bps) * duration / 8

            let fileLimit = UserDefaults.standard.integer(forKey: "VWFileLimit")

            if fileLimit != -1 {
                var desiredFileSize = Int64(fileSize)

                if fileLimit > 0 {
                    desiredFileSize = Int64(fileLimit)
                }

                exporter.fileLengthLimit = desiredFileSize
            }
        }

        await exporter.export()

        return outputUrl
    }

    func importVideo(_ url: URL) async throws {
        let videoTitle = url.deletingPathExtension().lastPathComponent
        var destinationUrl = folder.appendingPathComponent(videoTitle).appendingPathExtension(url.pathExtension)

        let convertedFile: URL
        if !UserDefaults.standard.bool(forKey: "shouldEnableVWCompression") {
            convertedFile = url
        } else {
            do {
                convertedFile = try await convert(url)
                destinationUrl = folder.appendingPathComponent(videoTitle).appendingPathExtension("mp4")
                print("Converted video", convertedFile.path)
            } catch {
                print(error)
                convertedFile = url
            }
        }

        try FileManager.default.moveItem(at: convertedFile, to: destinationUrl)
    }
}
