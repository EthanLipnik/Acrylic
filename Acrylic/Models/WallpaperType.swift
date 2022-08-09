//
//  WallpaperType.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/7/22.
//

#if os(macOS)
import Foundation

enum WallpaperType: String, CaseIterable {
    case fluid
    case video
    case nowPlaying
    
    var displayTitle: String {
        switch self {
        case .fluid:
            return "Fluid"
        case .video:
            return "Video"
        case .nowPlaying:
            return "Now Playing"
        }
    }
}
#endif
