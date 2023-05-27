//
//  GenerateMeshIntent.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/25/22.
//

import AppIntents
import CoreImage
import Foundation
import MeshKit

@available(iOS 16.0, macOS 13.0, *)
struct GenerateMeshIntent: AppIntent {
    static var title: LocalizedStringResource = "Generate Mesh Gradient"

    @Parameter(title: "Width", default: 1920, controlStyle: .field)
    var width: Int

    @Parameter(title: "Height", default: 1080, controlStyle: .field)
    var height: Int

    @Parameter(title: "Y", default: 3, controlStyle: .stepper, inclusiveRange: (3, 12))
    var x: Int

    @Parameter(title: "X", default: 3, controlStyle: .stepper, inclusiveRange: (3, 12))
    var y: Int

    @Parameter(
        title: "Grain Alpha",
        default: 0.5,
        controlStyle: .slider,
        inclusiveRange: (0.0, 1.0)
    )
    var grainAlpha: Double

    @Parameter(title: "Subdivisions", default: 18, controlStyle: .stepper, inclusiveRange: (2, 128))
    var subdivisions: Int

    @Parameter(
        title: "Location Randomizer Range",
        default: 0.2,
        controlStyle: .slider,
        inclusiveRange: (0.0, 0.8)
    )
    var locationRandomizeRange: Double

    @Parameter(
        title: "Turbulency Randomizer Range",
        default: 0.25,
        controlStyle: .slider,
        inclusiveRange: (0.0, 0.8)
    )
    var turbulencyRandomizeRange: Double

    @Parameter(title: "Palette", default: IntentPalette.random)
    var palette: IntentPalette

    @Parameter(title: "Luminosity", default: IntentLuminosity.vibrant)
    var luminosity: IntentLuminosity

    @Parameter(title: "Color Space", default: IntentColorSpace.sRGB)
    var colorSpace: IntentColorSpace

    func perform() async throws -> some IntentResult {
        let mesh = MeshKit.generate(
            palette: palette.palette,
            luminosity: luminosity.luminosity,
            size: MeshSize(width: x, height: y),
            withRandomizedLocations: true,
            locationRandomizationRange: -Float(locationRandomizeRange) ...
                Float(locationRandomizeRange),
            turbulencyRandomizationRange: -Float(turbulencyRandomizeRange) ...
                Float(turbulencyRandomizeRange)
        )

        let url = try await mesh.export(
            size: MeshSize(width: width, height: height),

            subdivisions: (subdivisions / 2) * 2,
            grainAlpha: Float(grainAlpha) / 10,
            colorSpace: CGColorSpace(name: colorSpace.cgSpace)
        )
        return .result(value: IntentFile(fileURL: url))
    }
}

@available(iOS 16.0, macOS 13.0, *)
enum IntentColorSpace: String, CaseIterable, Hashable, AppEnum {
    case linearSRGB
    case sRGB
    case displayP3

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Color Space"
    static var caseDisplayRepresentations: [IntentColorSpace: DisplayRepresentation] = [
        .linearSRGB: "Linear sRGB",
        .sRGB: "sRGB",
        .displayP3: "Display P3"
    ]

    var cgSpace: CFString {
        switch self {
        case .linearSRGB:
            return CGColorSpace.linearSRGB
        case .sRGB:
            return CGColorSpace.sRGB
        case .displayP3:
            return CGColorSpace.displayP3
        }
    }
}

@available(iOS 16.0, macOS 13.0, *)
enum IntentPalette: String, CaseIterable, Hashable, AppEnum {
    case blue
    case orange
    case yellow
    case green
    case pink
    case purple
    case red
    case monochrome
    case rainbow
    case random

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Palette"
    static var caseDisplayRepresentations: [IntentPalette: DisplayRepresentation] = [
        .blue: "Blue",
        .orange: "Orange",
        .yellow: "Yellow",
        .green: "Green",
        .pink: "Pink",
        .purple: "Purple",
        .red: "Red",
        .monochrome: "Monochrome",
        .rainbow: "Rainbow",
        .random: "Random"
    ]

    var palette: Hue {
        switch self {
        case .blue:
            return .blue
        case .orange:
            return .orange
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .pink:
            return .pink
        case .purple:
            return .purple
        case .red:
            return .red
        case .monochrome:
            return .monochrome
        case .rainbow:
            return .random
        case .random:
            return .randomPalette()
        }
    }
}

@available(iOS 16.0, macOS 13.0, *)
enum IntentLuminosity: String, CaseIterable, Hashable, AppEnum {
    case light
    case dark
    case vibrant

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Luminosity"
    static var caseDisplayRepresentations: [IntentLuminosity: DisplayRepresentation] = [
        .light: "Light",
        .dark: "Dark",
        .vibrant: "Vibrant"
    ]

    var luminosity: Luminosity {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .vibrant:
            return .bright
        }
    }
}
