//
//  SettingsView+VideoWallpaperView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/6/22.
//

import SwiftUI

#if os(macOS)
extension SettingsView {
    struct VideoWallpaperView: View {
        @AppStorage("shouldEnableVWCompression") private var shouldEnableCompression: Bool = false
        @AppStorage("VWFileLimit") private var fileLimit: Int = 0
        @AppStorage("shouldEnableVWSafeSearch") private var shouldEnableSafeSearch: Bool = true
        @AppStorage("VWSearchItemLimit") private var searchItemLimit: Int = 200
        
        var body: some View {
            Group {
                SectionView {
                    Toggle(isOn: $shouldEnableCompression) {
                        Text("Download Compression")
                        Text("Compression can improve battery life and file size.")
                    }
                    
                    Picker("File Size Limit", selection: $fileLimit) {
                        Text("20 MB")
                            .tag(20 * 1048576)
                        Text("50 MB")
                            .tag(50 * 1048576)
                        Text("100 MB")
                            .tag(100 * 1048576)
                        Text("150 MB")
                            .tag(150 * 1048576)
                        
                        Text("Original File Size")
                            .tag(0)
                        Text("No Limit")
                            .tag(-1)
                    }
                    .disabled(!shouldEnableCompression)
                } header: {
                    Label("Compression", systemImage: "doc.zipper")
                }
                
                SectionView {
                    Toggle(isOn: $shouldEnableSafeSearch) {
                        Text("Safe Search")
                    }
                    
                    Picker("Count Limit", selection: $searchItemLimit) {
                        Text("20")
                            .tag(20)
                        Text("50")
                            .tag(50)
                        Text("100")
                            .tag(100)
                        Text("150")
                            .tag(150)
                        Text("200")
                            .tag(200)
                    }
                } header: {
                    Label("Search", systemImage: "magnifyingglass.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
    }
}

struct SettingsView_VideoWallpaperView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView.VideoWallpaperView()
    }
}
#endif
