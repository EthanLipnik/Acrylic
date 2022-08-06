//
//  FluidWindow.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/4/22.
//

#if os(macOS)
import Cocoa
import SwiftUI

final class FluidWindow: WallpaperWindow {
    lazy var viewModel: FluidViewModel? = nil
    
    override var wallpaperType: WallpaperWindow.WallpaperType { return .fluid }
    
    override init() {
        super.init()
        
        let viewModel = FluidViewModel()
        viewModel.shouldUpdateDesktopPicture = true
        let screenSaverView = ScreenSaverView().environmentObject(viewModel)
        contentView = NSHostingView(rootView: screenSaverView)
        
        self.viewModel = viewModel
    }
    
    override func close() {
        contentView = nil
        viewModel?.destroy()
        viewModel = nil
        super.close()
    }
}
#endif
