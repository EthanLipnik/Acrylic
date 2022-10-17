//
//  StableDiffusionDownloaderView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/15/22.
//

import SwiftUI
import MeshKit

struct StableDiffusionDownloaderView: View {
    @StateObject private var downloader: MLModelDownloader = .init(
        url: URL(string: "https://mlmodels.b-cdn.net/bins.zip")!,
        destination: FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("StableDiffusion/bins")
    )
    
    var body: some View {
        Group {
            if downloader.didComplete {
                StableDiffusionView()
            } else {
                ProgressView(value: downloader.progress) {
                    HStack {
                        Text("Downloading model...")
                        Spacer()
                        Text(downloader.bytesWritten.formatted(.byteCount(style: .file)))
                            .monospacedDigit()
                            .bold()
                        + Text(" / ")
                            .foregroundColor(.secondary)
                        + Text(downloader.bytesTotal.formatted(.byteCount(style: .file)))
                            .monospacedDigit()
                    }
                    .drawingGroup()
                }
                .animation(.interactiveSpring(), value: downloader.progress)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Material.thick)
                )
                .padding()
            }
        }
        .onAppear {
            Task {
                do {
                    let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let folder = documents.appendingPathComponent("StableDiffusion")
                    
                    if !FileManager.default.fileExists(atPath: documents.path) {
                        try FileManager.default.createDirectory(at: documents, withIntermediateDirectories: true)
                    }
                    
                    if !FileManager.default.fileExists(atPath: folder.path) {
                        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
                    }
                    
                    print(downloader.destination.path)
                    if FileManager.default.fileExists(atPath: downloader.destination.path) {
                        downloader.didComplete = true
                    } else {
                        try downloader.download()
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
}

struct StableDiffusionDownloaderView_Previews: PreviewProvider {
    static var previews: some View {
        StableDiffusionDownloaderView()
    }
}
