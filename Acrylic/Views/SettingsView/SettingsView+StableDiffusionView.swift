//
//  SettingsView+StableDiffusionView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/17/22.
//

import SwiftUI

extension SettingsView {
    struct StableDiffusionView: View {
        @EnvironmentObject var downloadService: MLDownloadService

        @State private var hasImageModel: Bool = false
        @State private var hasUpscaleModel: Bool = false

        let imageModelDestination = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("StableDiffusion/bins")

        let upscaleModelDestination = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("CoreML/realesrgan512.mlmodel")

        var body: some View {
            Group {
                SectionView {
                    if let downloadUrl = URL(string: "https://mlmodels.b-cdn.net/bins.zip") {
                        if let download = downloadService.downloads[downloadUrl] {
                            DownloadView {
                                Text("Image Generation")
                                    .font(.headline)
                                    + Text(" (Required)")
                                    .foregroundColor(.secondary)
                            } didDeleteModel: {
                                hasImageModel = false
                            }
                            .environmentObject(download)
                        } else if !hasImageModel {
                            HStack {
                                Group {
                                    Text("Image Generation")
                                        .font(.headline)
                                        + Text(" (Required)")
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                Button("Download") {
                                    do {
                                        try downloadService.download(
                                            downloadUrl,
                                            destination: imageModelDestination
                                        )
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                            .transition(.blur.animation(.easeInOut))
                        } else {
                            let download: MLModelDownload = {
                                let download = MLModelDownload(url: downloadUrl, destination: imageModelDestination)
                                download.state = .done(bytesTotal: 2_222_645_575)
                                return download
                            }()

                            DownloadView {
                                Text("Image Generation")
                                    .font(.headline)
                                    + Text(" (Required)")
                                    .foregroundColor(.secondary)
                            } didDeleteModel: {
                                hasImageModel = false
                            }
                            .environmentObject(download)
                        }
                    }

                    if let downloadUrl = URL(string: "https://mlmodels.b-cdn.net/CoreML/realesrgan512.mlmodel.zip") {
                        if let download = downloadService.downloads[downloadUrl] {
                            DownloadView {
                                Text("Super Resolution")
                            } didDeleteModel: {
                                hasUpscaleModel = false
                            }
                            .environmentObject(download)
                        } else if !hasUpscaleModel {
                            HStack {
                                Group {
                                    Text("Super Resolution")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                Button("Download") {
                                    do {
                                        try downloadService.download(
                                            downloadUrl,
                                            destination: upscaleModelDestination,
                                            needsToCompile: true
                                        )
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                        } else {
                            let download: MLModelDownload = {
                                let download = MLModelDownload(url: downloadUrl, destination: upscaleModelDestination)
                                download.state = .done(bytesTotal: 67_300_000)
                                return download
                            }()

                            DownloadView {
                                Text("Super Resolution")
                            } didDeleteModel: {
                                hasUpscaleModel = false
                            }
                            .environmentObject(download)
                        }
                    }
                } header: {
                    Label("Model", systemImage: "shippingbox.fill")
                }
            }
            .onAppear {
                withAnimation(.none) {
                    hasImageModel = FileManager.default.fileExists(atPath: imageModelDestination.path)
                    hasUpscaleModel = FileManager.default.fileExists(atPath: upscaleModelDestination.path)
                    
                    print(imageModelDestination.path)
                }
            }
        }

        struct DownloadView<TitleView: View>: View {
            @Environment(\.mlDownloadService) var downloadService
            @EnvironmentObject var download: MLModelDownload

            @State private var isDeleting: Bool = false
            let title: TitleView
            let didDeleteModel: () -> Void

            init(@ViewBuilder title: () -> TitleView,
                 didDeleteModel: @escaping () -> Void)
            {
                self.title = title()
                self.didDeleteModel = didDeleteModel
            }

            var body: some View {
                Group {
                    switch download.state {
                    case .notStarted:
                        notStartedView
                    case let .downloading(progress, bytesWritten, bytesTotal):
                        downloadingView(progress: progress, bytesWritten: bytesWritten, bytesTotal: bytesTotal)
                    case .decompressing:
                        decompressingView
                    case .compiling:
                        compilingView
                    case let .done(total):
                        HStack {
                            title
                                .font(.headline)
                            Spacer()
                            Text(total.formatted(.byteCount(style: .file)))
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                            Button(role: .destructive) {
                                isDeleting.toggle()
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
                .confirmationDialog("Are you sure you want to delete the model?", isPresented: $isDeleting, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        do {
                            try FileManager.default.removeItem(at: download.destination)
                            didDeleteModel()
                        } catch {
                            print(error)
                        }
                    }

                    Button("Cancel", role: .cancel) {}
                }
            }

            var notStartedView: some View {
                ProgressView {
                    Label {
                        title
                    } icon: {
                        Image(systemName: "magnifyingglass.circle.fill")
                    }
                    .font(.headline)
                }
                .progressViewStyle(.linear)
            }

            @ViewBuilder
            func downloadingView(progress: Double, bytesWritten: Int64, bytesTotal: Int64) -> some View {
                HStack {
                    ProgressView(value: progress) {
                        Label {
                            title
                        } icon: {
                            Image(systemName: "arrow.down.circle.fill")
                        }
                        .font(.headline)
                    } currentValueLabel: {
                        Text(bytesWritten.formatted(.byteCount(style: .file)))
                            .monospacedDigit()
                            .bold()
                            + Text(" / ")
                            .foregroundColor(.secondary)
                            + Text(bytesTotal.formatted(.byteCount(style: .file)))
                            .monospacedDigit()
                    }
                    Button {
                        Task {
                            do {
                                let url = download.url
                                try await download.cancel()
                                downloadService.downloads.removeValue(forKey: url)
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
                        Image(systemName: "x.circle.fill")
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.secondary)
                }
            }

            var decompressingView: some View {
                ProgressView(value: 1) {
                    Label {
                        title
                    } icon: {
                        Image(systemName: "doc.zipper")
                    }
                    .font(.headline)
                } currentValueLabel: {
                    Text("Decompressing...")
                }
            }

            var compilingView: some View {
                ProgressView(value: 1) {
                    Label {
                        title
                    } icon: {
                        Image(systemName: "laptopcomputer.and.arrow.down")
                    }
                    .font(.headline)
                } currentValueLabel: {
                    Text("Compiling...")
                }
            }
        }
    }
}

struct SettingsView_StableDiffusionView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView.StableDiffusionView()
    }
}
