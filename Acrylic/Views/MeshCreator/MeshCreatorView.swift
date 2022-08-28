//
//  MeshCreatorView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 7/28/22.
//

import SwiftUI
import MeshKit

struct MeshCreatorView: View {
    @State private var meshRandomizer: MeshRandomizer
    @State private var colors: MeshColorGrid
    @State private var size: MeshSize

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
        meshRandomizer = .withMeshColors(colors)
        _size = .init(initialValue: size)
    }

    var body: some View {
        Group {
            if shouldAnimate {
                Mesh(colors: colors,
                     animatorConfiguration: .init(meshRandomizer: meshRandomizer),
                     grainAlpha: grainAlpha,
                     subdivisions: Int(subdivisions),
                     colorSpace: colorSpace.cgColorSpace)
            } else {
                Mesh(colors: colors,
                     grainAlpha: grainAlpha,
                     subdivisions: Int(subdivisions),
                     colorSpace: colorSpace.cgColorSpace)
            }
        }
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
        .overlay(
            ZStack {
                GrabberView(grid: $colors, selectedPoint: $selectedPoint) { x, y, translation, _ in
                    currentOffset = translation
                }
                Text("\(currentOffset.width) \(currentOffset.height)").hidden()
            }
            .edgesIgnoringSafeArea([.bottom, .horizontal])
            .allowsHitTesting(!shouldAnimate)
        )
        .onTapGesture {
            selectedPoint = nil
        }
    }
    
    func newPalette(_ palette: Hue? = nil, luminosity: Luminosity = .bright) {
        let oldColors = colors
        let colors = MeshKit.generate(palette: palette ?? .randomPalette(), luminosity: luminosity, size: size)
        
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

    struct GrabberView: View {
        @Binding var grid: MeshColorGrid
        @Binding var selectedPoint: MeshColor?

        var didMovePoint: (_ x: Int, _ y: Int, _ translation: CGSize, _ meshPoint: MeshPoint) -> Void

        var body: some View {
            GeometryReader { proxy in
                ZStack {
                    ForEach(0..<grid.width, id: \.self) { x in
                        ForEach(0..<grid.height, id: \.self) { y in
                            let offset = (grid.height - 1)
                            let isEdge = grid.isEdge(x: x, y: y)
                            
                            let xOffset = CGFloat(Int(proxy.size.width) * x) / CGFloat(grid.width - 1)
                            let yOffset = CGFloat(Int(proxy.size.height) * y) / CGFloat(grid.height - 1)
                            
                            PointView(point: $grid[x, offset - y], grid: $grid, selectedPoint: $selectedPoint, proxy: proxy, isEdge: isEdge) { translation, meshPoint in
                                didMovePoint(x, offset - y, translation, meshPoint)
                            }
                            .offset(
                                x: xOffset - (x + 1 == grid.width ? 60 : 0) + (x == 0 ? 30 : -30),
                                y: yOffset - (y + 1 == grid.height ? 60 : 0) + (y == 0 ? 30 : -30)
                            )
                        }
                    }
                }
            }
        }

        struct PointView: View {
            @Binding var point: MeshColor
            @Binding var grid: MeshColorGrid
            @Binding var selectedPoint: MeshColor?
            let proxy: GeometryProxy
            let isEdge: Bool
            var didMove: (_ translation: CGSize, _ point: MeshPoint) -> Void

            @State private var offset: CGSize = .zero

            var body: some View {
                Circle()
                    .fill(selectedPoint == point ? Color.white : Color.black.opacity(0.2))
                    .scaleEffect(selectedPoint == point ? 1.1 : 1)
                    .scaleEffect(isEdge ? 0.5 : 1)
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 8)
                    .offset(offset)
                    .animation(.interactiveSpring(), value: offset)
                    .animation(.easeInOut, value: selectedPoint)
                    .frame(maxWidth: 35, maxHeight: 35)
                    .onTapGesture {
                        selectedPoint = point
                    }
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                selectedPoint = point

                                guard !isEdge else { return }

                                let location = value.location
                                var width = location.x / (proxy.size.width / 2)
                                var height = location.y / (proxy.size.height / 2)

                                width = min(0.3, max(-0.3, width))
                                height = min(0.3, max(-0.3, height))
                                
                                let meshPoint = MeshPoint(x: Float(width) + point.startLocation.x, y: -Float(height) + point.startLocation.y)
                                point.location = meshPoint

                                let offsetWidth = -proxy.size.width / CGFloat(grid.width)
                                let offsetX = min(abs(offsetWidth) - 45, max(offsetWidth + 45, location.x))

                                let offsetHeight = -proxy.size.height / CGFloat(grid.height)
                                let offsetY = min(abs(offsetHeight) - 45, max(offsetHeight + 45, location.y))
                                offset = CGSize(width: offsetX, height: offsetY)

                                didMove(CGSize(width: width, height: 1 - height), meshPoint)
                            })
                    )
            }
        }
    }
}

struct MeshCreatorView_Previews: PreviewProvider {
    static var previews: some View {
        MeshCreatorView()
    }
}
