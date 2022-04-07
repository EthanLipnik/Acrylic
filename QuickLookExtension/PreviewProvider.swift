//
//  PreviewProvider.swift
//  QuickLookExtension
//
//  Created by Ethan Lipnik on 3/28/22.
//

import QuickLook

class PreviewProvider: QLPreviewProvider, QLPreviewingController {
    
    
    /*
     Use a QLPreviewProvider to provide data-based previews.
     
     To set up your extension as a data-based preview extension:
     
     - Modify the extension's Info.plist by setting
     <key>QLIsDataBasedPreview</key>
     <true/>
     
     - Add the supported content types to QLSupportedContentTypes array in the extension's Info.plist.
     
     - Remove
     <key>NSExtensionMainStoryboard</key>
     <string>MainInterface</string>
     
     and replace it by setting the NSExtensionPrincipalClass to this class, e.g.
     <key>NSExtensionPrincipalClass</key>
     <string>$(PRODUCT_MODULE_NAME).PreviewProvider</string>
     
     - Implement providePreview(for:)
     */
    
    func providePreview(for request: QLFilePreviewRequest) async throws -> QLPreviewReply {
        
        //You can create a QLPreviewReply in several ways, depending on the format of the data you want to return.
        //To return Data of a supported content type:
        
        let imageUrl = request.fileURL.appendingPathComponent("PreviewImage")
        let image = UIImage(contentsOfFile: imageUrl.path)
        let reply = QLPreviewReply(dataOfContentType: .image, contentSize: image?.size ?? CGSize(width: 512, height: 512)) { reply in
            
            return image?.pngData() ?? (try? Data(contentsOf: imageUrl)) ?? .init()
        }
        
        return reply
    }
    
}
