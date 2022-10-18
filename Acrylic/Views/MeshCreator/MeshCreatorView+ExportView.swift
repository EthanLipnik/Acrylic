//
//  MeshCreatorView+ExportView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 8/20/22.
//

import MeshKit
import SwiftUI
import UniformTypeIdentifiers

extension MeshCreatorView {
    struct ExportView: View {
        let colors: MeshColorGrid

        @Binding var imageFile: ImageDocument?
        @Binding var shouldExportFile: Bool
        @State var colorSpace: ColorSpace = .sRGB
        @State var quality: Quality = .normal
        @State var fileFormat: FileFormat = .PNG
        @State var aspectRatio: AspectRatio = .square
        @State var isVertical: Bool = false
        @State var resolution: Resolution = .medium

        @State var isExporting: Bool = false

        enum AspectRatio: Hashable {
            case square
            case classic
            case standard
            case wide

            var rawValue: Double {
                switch self {
                case .square:
                    return 1
                case .classic:
                    return 4 / 3
                case .standard:
                    return 16 / 9
                case .wide:
                    return 2 / 1
                }
            }
        }

        enum FileFormat: String, Hashable, CaseIterable {
            case PNG
            case JPEG
            case HEIC

            var type: UTType {
                switch self {
                case .PNG:
                    return .png
                case .JPEG:
                    return .jpeg
                case .HEIC:
                    return .heic
                }
            }
        }

        enum Resolution: Int, Hashable, CaseIterable {
            case low = 1280
            case medium = 1920
            case high = 3072
            case ultra = 6144
            case extreme = 7680

            var displayName: String {
                switch self {
                case .low:
                    return "720p"
                case .medium:
                    return "1080p"
                case .high:
                    return "4K"
                case .ultra:
                    return "6K"
                case .extreme:
                    return "8K"
                }
            }
        }

        enum Quality: Int, Hashable, CaseIterable {
            case low = 4
            case normal = 18
            case high = 32
            case ultra = 64
            case extreme = 128

            var displayName: String {
                switch self {
                case .low:
                    return "Low"
                case .normal:
                    return "Normal"
                case .high:
                    return "High"
                case .ultra:
                    return "Ultra"
                case .extreme:
                    return "Extreme"
                }
            }
        }

        var body: some View {
            VStack {
                Form {
//                    Picker("Format", selection: $fileFormat) {
//                        ForEach(FileFormat.allCases, id: \.rawValue) { format in
//                            Text(format.rawValue)
//                                .tag(format)
//                        }
//                    }

                    Picker("Color Space", selection: $colorSpace) {
                        ForEach(ColorSpace.allCases, id: \.rawValue) { colorSpace in
                            Text(colorSpace.displayName)
                                .tag(colorSpace)
                        }
                    }

                    Picker("Quality", selection: $quality) {
                        ForEach(Quality.allCases, id: \.rawValue) { quality in
                            Text(quality.displayName)
                                .tag(quality)
                        }
                    }
                    .pickerStyle(.radioGroup)

                    Picker("Resolution", selection: $resolution) {
                        ForEach(Resolution.allCases, id: \.rawValue) { resolution in
                            Text(resolution.displayName)
                                .tag(resolution)
                        }
                    }
                    .pickerStyle(.radioGroup)

                    aspectRatioView
                }

                Divider()

                Button("Export") {
                    Task(priority: .high) {
                        isExporting = true

                        do {
                            let size: MeshSize = {
                                if isVertical {
                                    return .init(width: resolution.rawValue,
                                                 height: Int(Double(resolution.rawValue) * aspectRatio.rawValue))
                                } else {
                                    return .init(width: Int(Double(resolution.rawValue) * aspectRatio.rawValue),
                                                 height: resolution.rawValue)
                                }
                            }()

                            let url = try await colors.export(size: size,
                                                              subdivisions: quality.rawValue,
                                                              colorSpace: colorSpace.cgColorSpace)
                            if let image = NSImage(contentsOfFile: url.path) {
                                imageFile = .init(image: image)
                                shouldExportFile = true
                            }
                        } catch {
                            print(error)
                        }

                        isExporting = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isExporting)
            }
            .padding()
            .frame(width: 300)
            .fixedSize(horizontal: false, vertical: true)
        }

        var aspectRatioView: some View {
            HStack {
                Picker("Aspect Ratio", selection: $aspectRatio) {
                    Text("1:1")
                        .tag(AspectRatio.square)
                    Text("4:3")
                        .tag(AspectRatio.classic)
                    Text("16:9")
                        .tag(AspectRatio.standard)
                    Text("2:1")
                        .tag(AspectRatio.wide)
                }

                Toggle(isOn: $isVertical) {
                    Image(systemName: isVertical ? "trapezoid.and.line.vertical.fill" : "trapezoid.and.line.vertical")
                }
                .toggleStyle(.button)
            }
        }
    }
}

struct MeshCreatorView_ExportView_Previews: PreviewProvider {
    static var previews: some View {
        MeshCreatorView.ExportView(colors: MeshKit.generate(palette: .blue), imageFile: .constant(nil), shouldExportFile: .constant(false))
    }
}

struct ImageDocument: FileDocument {
    var image: NSImage

    init(image: NSImage) {
        self.image = image
    }

    static var readableContentTypes: [UTType] { [.image, .png, .jpeg, .heic] }
    static var writableContentTypes: [UTType] { [.image, .png, .jpeg, .heic] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let image = NSImage(data: data)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.image = image
    }

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        guard let data = image.pngData else { throw CocoaError(.fileNoSuchFile) }
        return .init(regularFileWithContents: data)
    }
}
