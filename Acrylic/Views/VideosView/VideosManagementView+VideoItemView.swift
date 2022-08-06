//
//  VideosManagementView+VideoItemView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/5/22.
//

import SwiftUI
import PixabayKit

extension VideosManagementView {
    struct VideoItemView: View {
        let video: Video
        
        var body: some View {
            AsyncImage(url: URL(string: "https://i.vimeocdn.com/video/\(video.pictureID)_\(720).jpg")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                case .failure(let error):
                    Color.red
                        .onAppear {
                            print(error)
                        }
                case .empty:
                    Color.secondary
                @unknown default:
                    Color.secondary
                }
            }
            .aspectRatio(16/9, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            .drawingGroup()
            .shadow(radius: 8, y: 4)
        }
    }
}
