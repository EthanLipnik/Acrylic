//
//  VideosManagementView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/5/22.
//

import SwiftUI
import PixabayKit
import AVKit
import Sebu

struct VideosManagementView: View {
    @State private var selectedCategory: SearchCategory? = .all
    
    var body: some View {
        Group {
            if #available(iOS 16.0, macOS 13.0, *) {
                NavigationSplitView {
                    SidebarView(selectedCategory: $selectedCategory)
                } detail: {
                    VideosView(category: $selectedCategory)
                }
            } else {
                NavigationView {
                    SidebarView(selectedCategory: $selectedCategory)
                    VideosView(category: $selectedCategory)
                }
            }
        }
        .navigationTitle("Videos")
    }
}

struct VideosManagementView_Previews: PreviewProvider {
    static var previews: some View {
        VideosManagementView()
    }
}
