//
//  StableDiffusionDownloaderView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/15/22.
//

import MeshKit
import SwiftUI

struct StableDiffusionDownloaderView: View {
    let binsLocation = FileManager.default.urls(
        for: .applicationSupportDirectory,
        in: .userDomainMask
    )[0].appendingPathComponent("StableDiffusion/bins")

    var body: some View {
        Group {
            if FileManager.default.fileExists(atPath: binsLocation.path) {
                StableDiffusionView()
            } else {
                Text("Download the model in Acrylic settings")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct StableDiffusionDownloaderView_Previews: PreviewProvider {
    static var previews: some View {
        StableDiffusionDownloaderView()
    }
}
