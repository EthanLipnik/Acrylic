//
//  MLModelDownloader.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/15/22.
//

import CoreML
import Foundation
import SwiftUI
import ZIPFoundation

class MLDownloadService: ObservableObject {
    @Published var downloads: [URL: MLModelDownload] = [:]

    func download(_ url: URL, destination: URL, needsToCompile: Bool = false) throws {
        guard downloads[url] == nil else { return }

        let download = MLModelDownload(url: url, destination: destination, needsToCompile: needsToCompile)
        try download.download()

        DispatchQueue.main.async {
            self.downloads[url] = download
        }
    }
}

class MLModelDownload: NSObject, ObservableObject, URLSessionDownloadDelegate {
    let url: URL
    let destination: URL
    let needsToCompile: Bool

    @Published var state: State = .notStarted

    private lazy var downloadTask: URLSessionDownloadTask? = nil

    enum State: Equatable {
        case notStarted
        case downloading(progress: Double, bytesWritten: Int64, bytesTotal: Int64)
        case decompressing
        case compiling
        case done(bytesTotal: Int64)
    }

    init(url: URL, destination: URL, needsToCompile: Bool = false) {
        self.url = url
        self.destination = destination
        self.needsToCompile = needsToCompile
    }

    func download() throws {
        state = .notStarted
        let tempDirectory = FileManager.default.temporaryDirectory
        let applicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]

        if !FileManager.default.fileExists(atPath: tempDirectory.path) {
            try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        }

        if !FileManager.default.fileExists(atPath: applicationSupportDirectory.path) {
            try FileManager.default.createDirectory(at: applicationSupportDirectory, withIntermediateDirectories: true)
        }

        var downloadRequest = URLRequest(url: url)
        downloadRequest.allowsExpensiveNetworkAccess = true
        downloadRequest.allowsCellularAccess = true
        downloadRequest.networkServiceType = .responsiveData
        downloadRequest.cachePolicy = .reloadIgnoringCacheData

        #if !os(macOS)
            let bundleIdentifer = Bundle.main.bundleIdentifier ?? "acrylic"
            let config = URLSessionConfiguration.background(withIdentifier: "com.networking." + bundleIdentifer)
            config.isDiscretionary = false
            config.sessionSendsLaunchEvents = true
            config.allowsCellularAccess = downloadRequest.allowsCellularAccess
            config.allowsExpensiveNetworkAccess = downloadRequest.allowsExpensiveNetworkAccess
            config.requestCachePolicy = downloadRequest.cachePolicy
            let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        #else
            let session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
        #endif

        let downloadTask = session
            .downloadTask(with: downloadRequest)
        downloadTask.resume()
        self.downloadTask = downloadTask
        state = .downloading(progress: 0, bytesWritten: 0, bytesTotal: 0)
    }
    
    func cancel() async throws {
        downloadTask?.cancel()
        downloadTask = nil
    }

    func urlSession(_: URLSession, downloadTask: URLSessionDownloadTask, didWriteData _: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard downloadTask == self.downloadTask else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            self.state = .downloading(progress: progress, bytesWritten: totalBytesWritten, bytesTotal: totalBytesExpectedToWrite)
        }
    }

    func urlSession(_: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard downloadTask == self.downloadTask else { return }

        do {
            guard let file = try FileManager.default.replaceItemAt(FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent), withItemAt: location)
            else { return }

            Task(priority: .userInitiated) {
                do {
                    Task.detached { @MainActor in
                        self.state = .decompressing
                    }

                    let unzipLocation = FileManager.default.temporaryDirectory.appendingPathComponent("Download \(Date())".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)

                    if FileManager.default.fileExists(atPath: destination.path) {
                        try FileManager.default.removeItem(at: destination)
                    }

                    if FileManager.default.fileExists(atPath: unzipLocation.path) {
                        try FileManager.default.removeItem(at: unzipLocation)
                    }

                    try FileManager.default.unzipItem(at: file, to: unzipLocation)

                    let destinationFolder = destination.deletingLastPathComponent()

                    if !FileManager.default.fileExists(atPath: destinationFolder.path) {
                        try FileManager.default.createDirectory(at: destinationFolder, withIntermediateDirectories: true)
                    }

                    if needsToCompile {
                        Task.detached { @MainActor in
                            self.state = .compiling
                        }

                        // Get MLModel file based on the CDN URL (removing .zip)
                        let modelLocation = unzipLocation.appendingPathComponent(self.url.deletingPathExtension().lastPathComponent)
                        let compiledModel = try await MLModel.compileModel(at: modelLocation)
                        _ = try FileManager.default.replaceItemAt(destination, withItemAt: compiledModel)
                    } else {
                        _ = try FileManager.default.replaceItemAt(destination, withItemAt: unzipLocation.appendingPathComponent(destination.lastPathComponent))
                    }

                    try? FileManager.default.removeItem(at: unzipLocation)
                    try? FileManager.default.removeItem(at: file)

                    Task.detached { @MainActor in
                        let fileSize = Int64(self.destination.fileSize)
                        self.state = .done(bytesTotal: fileSize)
                        print("Finished downloading:", self.destination.path)
                    }
                } catch {
                    print(error)
                    try? await cancel()
                }
            }
        } catch {
            print(error)
        }
    }
}

private struct MLDownloaderKey: EnvironmentKey {
    static let defaultValue = MLDownloadService()
}

extension EnvironmentValues {
    var mlDownloadService: MLDownloadService {
        get { self[MLDownloaderKey.self] }
        set { self[MLDownloaderKey.self] = newValue }
    }
}
