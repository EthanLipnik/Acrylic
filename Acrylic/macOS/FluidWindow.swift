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
    
    init() {
        let viewModel = FluidViewModel()
        viewModel.shouldUpdateDesktopPicture = true
        let screenSaverView = ScreenSaverView().environmentObject(viewModel)
        super.init(view: screenSaverView)
        self.viewModel = viewModel
    }
    
    required init(view: some View) {
        fatalError("init(view:) has not been implemented")
    }
    
    override func close() {
        contentView = nil
        viewModel?.destroy()
        viewModel = nil
        super.close()
    }
}
#endif
