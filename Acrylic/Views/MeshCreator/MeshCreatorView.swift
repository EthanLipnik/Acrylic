//
//  MeshCreatorView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 7/28/22.
//

import SwiftUI
import MeshKit

struct MeshCreatorView: View {
    @State private var meshRandomizer: MeshRandomizer?
    @State private var colors: MeshColorGrid

    @State private var shouldAnimate: Bool = false
    @State private var grainAlpha: Float = MeshDefaults.grainAlpha
    @State private var subdivisions: Float = Float(MeshDefaults.subdivisions)

    @State private var shouldShowOptions: Bool = false
    @State private var selectedPoint: MeshColor?

    @State private var currentOffset: CGSize = .zero

    @State private var showSettings: Bool = false

    @State private var shouldExport: Bool = false
    @State private var imageFile: ImageDocument?
    @State private var shouldExportFile: Bool = false

    @AppStorage("colorSpace") private var colorSpace: ColorSpace = .sRGB

    private let defaultBackgroundColor: SystemColor = {
        return NSColor.windowBackgroundColor
    }()

    init() {
        let size = MeshSize(width: 5, height: 5)
        let colors = MeshKit.generate(palette: .randomPalette(), size: size)
        _colors = .init(initialValue: colors)
    }

    var body: some View {
        MeshEditor(
            colors: $colors,
            selectedPoint: $selectedPoint,
            meshRandomizer: meshRandomizer,
            grainAlpha: grainAlpha,
            subdivisions: subdivisions,
            colorSpace: colorSpace.cgColorSpace
        )
        .background(Color(colors.elements.first?.color ?? defaultBackgroundColor).edgesIgnoringSafeArea(.all))
        .edgesIgnoringSafeArea([.bottom, .horizontal])
        .animation(.easeInOut(duration: shouldAnimate ? 5 : 0.2), value: colors)
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Menu {
                    ForEach(Hue.allCases, id: \.self) { hue in
                        Menu {
                            Button("Light") {
                                newPalette(hue, luminosity: .light)
                            }
                            Button("Dark") {
                                newPalette(hue, luminosity: .dark)
                            }
                            Button("Vibrant") {
                                newPalette(hue, luminosity: .bright)
                            }
                        } label: {
                            Text(hue.displayTitle)
                        } primaryAction: {
                            newPalette(hue)
                        }
                    }
                } label: {
                    Label("Randomize", systemImage: "arrow.triangle.2.circlepath")
                } primaryAction: {
                    newPalette()
                }
            }

            ToolbarItem(id: "options") {
                Button {
                    shouldShowOptions.toggle()
                } label: {
                    Label("Options", systemImage: "ellipsis")
                }
                .popover(isPresented: $shouldShowOptions) {
                    OptionsView(grainAlpha: $grainAlpha, subdivisions: $subdivisions)
                }
            }

            ToolbarItem(id: "animate") {
                Toggle(isOn: $shouldAnimate) {
                    Label("Animate", systemImage: "square.stack.3d.forward.dottedline")
                }
                .onChange(of: shouldAnimate) { newValue in
                    if newValue {
                        meshRandomizer = .withMeshColors(colors)
                    } else {
                        meshRandomizer = nil
                    }
                }
            }

            ToolbarItem(id: "save", placement: .primaryAction, showsByDefault: true) {
                Button {
                    shouldExport.toggle()
                } label: {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .popover(isPresented: $shouldExport) {
                    ExportView(colors: colors, imageFile: $imageFile, shouldExportFile: $shouldExportFile)
                }
                .fileExporter(isPresented: $shouldExportFile, document: imageFile, contentType: .png, defaultFilename: "Mesh") { result in
                    switch result {
                    case .success(let url):
                        print(url.path)
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
        .onTapGesture {
            selectedPoint = nil
        }
    }

    func newPalette(_ palette: Hue? = nil, luminosity: Luminosity = .bright) {
        let oldColors = colors
        let colors = MeshKit.generate(palette: palette ?? .randomPalette(), luminosity: luminosity, size: .init(width: oldColors.width, height: oldColors.height))

        for y in stride(from: 0, to: colors.width, by: 1) {
            for x in stride(from: 0, to: colors.height, by: 1) {
                colors[x, y].location = oldColors[x, y].location
            }
        }

        self.colors = colors
        meshRandomizer = .withMeshColors(self.colors)
    }

    struct OptionsView: View {
        @Binding var grainAlpha: Float
        @Binding var subdivisions: Float

        var body: some View {
            VStack {
                HStack {
                    Label("Grain", systemImage: "circle.grid.3x3.fill")
                        .frame(width: 150, alignment: .leading)
                    Slider(value: $grainAlpha, in: 0.01...0.25) {
                        Text("Grain")
                    }.labelsHidden()
                }
                HStack {
                    Label("Subdivisions", systemImage: "cube.fill")
                        .frame(width: 150, alignment: .leading)
                    Slider(value: $subdivisions, in: 2...32, step: 1.0) {
                        Text("Subdivisions")
                    }.labelsHidden()
                }
            }
            .padding()
            .frame(minWidth: 400)
        }
    }
}

struct MeshCreatorView_Previews: PreviewProvider {
    static var previews: some View {
        MeshCreatorView()
    }
}
