//
//  VideosManagementView+VideoItemView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/5/22.
//

import PixabayKit
import SDWebImageSwiftUI
import SwiftUI

extension VideosManagementView {
    struct VideoItemView: View {
        let video: Video

        var body: some View {
            WebImage(
                url: URL(string: "https://i.vimeocdn.com/video/\(video.pictureID)_\(720).jpg"),
                options: [.scaleDownLargeImages]
            )
            .resizable()
            .background(Color.secondary)
            .aspectRatio(16 / 9, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}
