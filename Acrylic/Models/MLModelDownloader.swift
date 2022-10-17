//
//  MLModelDownloader.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/15/22.
//

import Foundation
import ZIPFoundation

class MLModelDownloader: NSObject, ObservableObject, URLSessionDownloadDelegate {
    let url: URL
    let destination: URL
    
    @Published var progress: Double = 0
    @Published var bytesWritten: Int64 = 0
    @Published var bytesTotal: Int64 = 0
    @Published var didComplete: Bool = false
    
    private lazy var downloadTask: URLSessionDownloadTask? = nil
    
    init(url: URL, destination: URL) {
        self.url = url
        self.destination = destination
    }
    
    func download() throws {
        print("Downloading model")
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
        downloadRequest.cachePolicy = .returnCacheDataElseLoad
        
        let bundleIdentifer = Bundle.main.bundleIdentifier ?? "acrylic"
        let config = URLSessionConfiguration.background(withIdentifier: "com.networking." + bundleIdentifer)
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        config.allowsCellularAccess = true
        config.allowsExpensiveNetworkAccess = true
        
        let downloadTask = URLSession(configuration: config, delegate: self, delegateQueue: nil)
            .downloadTask(with: downloadRequest)
        downloadTask.resume()
        self.downloadTask = downloadTask
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard downloadTask == self.downloadTask else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.bytesWritten = totalBytesWritten
            self.bytesTotal = totalBytesExpectedToWrite
            
            let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            
            if Int(self.progress) != Int(progress) {
                print("💿 Downloading stable diffusion model", Int(progress * 100), "%")
            }
            
            self.progress = min(1, progress)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let unzipLocation = FileManager.default.temporaryDirectory.appendingPathComponent("Download")
            
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            
            if FileManager.default.fileExists(atPath: unzipLocation.path) {
                try FileManager.default.removeItem(at: unzipLocation)
            }
            
            try FileManager.default.unzipItem(at: location, to: unzipLocation)
            
            if !FileManager.default.fileExists(atPath: destination.deletingLastPathComponent().path) {
                try FileManager.default.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
            }
            
            try FileManager.default.moveItem(at: unzipLocation.appendingPathComponent(destination.lastPathComponent), to: destination)
            
            didComplete = true
        } catch {
            print(error)
        }
    }
}
