//
//  VideosManagementView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/5/22.
//

import AVKit
import PixabayKit
import Sebu
import SwiftUI

struct VideosManagementView: View {
    @State private var selectedCategory: SearchCategory? = .backgrounds

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedCategory: $selectedCategory)
        } detail: {
            VideosView(category: $selectedCategory)
        }
        .navigationTitle("Videos")
    }
}

struct VideosManagementView_Previews: PreviewProvider {
    static var previews: some View {
        VideosManagementView()
    }
}
