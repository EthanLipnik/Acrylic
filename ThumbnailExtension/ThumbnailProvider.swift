//
//  ThumbnailProvider.swift
//  ThumbnailExtension
//
//  Created by Ethan Lipnik on 3/28/22.
//

import UIKit
import QuickLookThumbnailing

class ThumbnailProvider: QLThumbnailProvider {
    
    override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
        
        // There are three ways to provide a thumbnail through a QLThumbnailReply. Only one of them should be used.
        
        // First way: Draw the thumbnail into the current context, set up with UIKit's coordinate system.
        switch request.fileURL.pathExtension {
        case "ausf", "amgf":
            handler(QLThumbnailReply(imageFileURL: request.fileURL.appendingPathComponent("PreviewImage")), nil)
        default:
            handler(nil, CocoaError(.fileReadUnknown))
        }
    }
}
