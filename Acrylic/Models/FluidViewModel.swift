//
//  FluidViewModel.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/3/22.
//

import Foundation
import MeshKit
import SwiftUI
import AppKit

class FluidViewModel: ObservableObject {
    @Published var meshRandomizer: MeshRandomizer
    @Published var colors: MeshGrid
    @Published var timer: Timer?

    private let fluidWallpapersFolder = FileManager.default
        .temporaryDirectory
        .appendingPathComponent("Fluid Wallpapers")
    var shouldUpdateDesktopPicture: Bool = false

    var allowedPalettes: [Hue] {
        return Hue.allCases.filter({ !UserDefaults.standard.bool(forKey: "isWallpaperPalette-\($0.displayTitle)Disabled") })
    }

    init() {
        let colors = MeshKit.generate(palette: .monochrome, luminosity: .dark)
        self.colors = colors
        self.meshRandomizer = .withMeshColors(colors)

        do {
            if FileManager.default.fileExists(atPath: fluidWallpapersFolder.path) {
                try FileManager.default.removeItem(at: fluidWallpapersFolder)
            }

            try FileManager.default.createDirectory(at: fluidWallpapersFolder, withIntermediateDirectories: true)
        } catch {
            print(error)
        }
    }

    deinit {
        timer?.invalidate()
        timer = nil
    }

    func destroy() {
        timer?.invalidate()
        timer = nil
    }

    func newPalette(_ palette: Hue? = nil) {
        let luminosity: Luminosity = {
            let interfaceStyle = InterfaceStyle()
            let wallpaperColorScheme =  WallpaperColorScheme(rawValue: UserDefaults.standard.string(forKey: "FWColorScheme") ?? "system")
            switch wallpaperColorScheme {
            case .light:
                return .light
            case .dark:
                return .dark
            case .system:
                return interfaceStyle == .Light ? .light : .dark
            default:
                return .bright
            }
        }()

        colors = MeshKit.generate(palette: palette ?? allowedPalettes.randomElement() ?? .monochrome, luminosity: luminosity, withRandomizedLocations: true)
        meshRandomizer = .withMeshColors(colors)

        if shouldUpdateDesktopPicture {
            let animationSpeed = AnimationSpeed(rawValue: UserDefaults.standard.string(forKey: "FWAnimationSpeed") ?? "normal") ?? .normal
            let delay: Double = {
                switch animationSpeed {
                case .slow:
                    return 8
                case .normal:
                    return 4
                case .fast:
                    return 2
                }
            }()
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.updateDesktopPicture()
            }
        }
    }

    func setTimer(_ interval: Double = FluidViewModel.getDefaultChangeInterval()) {
        timer?.invalidate()
        timer = nil

        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(generateNewPalette), userInfo: nil, repeats: true)
    }

    @objc
    private func generateNewPalette() {
        newPalette()
    }

    static func getDefaultChangeInterval() -> Double {
        if UserDefaults.standard.object(forKey: "FWPaletteChangeInterval") != nil {
            return UserDefaults.standard.double(forKey: "FWPaletteChangeInterval")
        }

        return 60
    }

    func updateDesktopPicture() {

        var color: NSColor
        if (UserDefaults.standard.object(forKey: "shouldColorMatchFWMenuBar") as? Bool) ?? true {
            color = colors.elements.first?.color ?? .black
        } else {
            color = .black
        }

        do {
            let image = NSImage(color: color, size: NSSize(width: 10, height: 10))
            guard let imageData = image.pngData else { return }
            let url = fluidWallpapersFolder.appendingPathComponent("Acrylic Fluid Wallpaper \(Date()).png")
            if FileManager.default.fileExists(atPath: url.path) {
                try? FileManager.default.removeItem(at: url)
            }
            try imageData.write(to: url)

            let workspace = NSWorkspace.shared
            if let screen = NSScreen.main {
                try workspace.setDesktopImageURL(url, for: screen)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                try? FileManager.default.removeItem(at: url)
            }
        } catch {
            print(error)
        }
    }

    enum InterfaceStyle: String {
        case Dark, Light

        init() {
            let type = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
            self = InterfaceStyle(rawValue: type)!
        }
    }
}

extension NSImage {
    convenience init(color: NSColor, size: NSSize) {
        self.init(size: size)
        lockFocus()
        color.drawSwatch(in: NSRect(origin: .zero, size: size))
        unlockFocus()
    }

    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }

    func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) throws {
        try pngData?.write(to: url, options: options)
    }
}
