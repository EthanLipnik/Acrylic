//
//  NowPlayingWindow.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/9/22.
//

import Cocoa
import SwiftUI

final class NowPlayingWindow: WallpaperWindow {
    lazy var viewModel: FluidViewModel? = nil

    override var wallpaperType: WallpaperType? { return .nowPlaying }

    override init() {
        super.init()

        let viewModel = FluidViewModel()
        viewModel.shouldUpdateDesktopPicture = true
        let screenSaverView = ScreenSaverView().environmentObject(viewModel)
        contentView = NSHostingView(rootView: screenSaverView)

        self.viewModel = viewModel

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard self?.viewModel != nil else { return }
            viewModel.newPalette()
        }
    }

    override func close() {
        contentView = nil
        viewModel?.destroy()
        viewModel = nil
        super.close()
    }
}
