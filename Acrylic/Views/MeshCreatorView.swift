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

    @State private var currentXOffset: CGFloat = 0
    @State private var currentYOffset: CGFloat = 0

    @State private var showSettings: Bool = false

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
                     subdivisions: Int(subdivisions))
            } else {
                Mesh(colors: colors,
                     grainAlpha: grainAlpha,
                     subdivisions: Int(subdivisions))
            }
        }
        .background(Color(colors.elements.first?.color ?? defaultBackgroundColor).edgesIgnoringSafeArea(.all))
        .edgesIgnoringSafeArea([.bottom, .horizontal])
        .animation(.easeInOut(duration: shouldAnimate ? 5 : 0.2), value: colors)
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Button {
                    colors = MeshKit.generate(palette: .randomPalette(), size: size)
                    meshRandomizer = .withMeshColors(colors)
                } label: {
                    Label("Randomize", systemImage: "arrow.triangle.2.circlepath")
                }
                .keyboardShortcut("r")
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

                } label: {
                    Label("Save", systemImage: "square.and.arrow.up")
                }
            }
        }
        .overlay(
            ZStack {
                GrabberView(grid: $colors, selectedPoint: $selectedPoint) { _, _, translation in
                    currentXOffset = translation.width
                    currentYOffset = translation.height
                }
                Slider(value: $currentXOffset, in: -5...5) {
                    Text("x")
                }
                .hidden()

                Slider(value: $currentYOffset, in: -5...5) {
                    Text("y")
                }
                .hidden()
            }
            .edgesIgnoringSafeArea([.bottom, .horizontal])
        )
        .onTapGesture {
            selectedPoint = nil
        }
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

        var didMovePoint: (_ x: Int, _ y: Int, _ translation: CGSize) -> Void

        var body: some View {
            GeometryReader { proxy in
                HStack {
                    ForEach(0..<grid.width, id: \.self) { x in
                        VStack {
                            ForEach(0..<grid.height, id: \.self) { y in
                                Spacer()
                                let offset = (grid.height - 1)
                                let isEdge = grid.isEdge(x: x, y: y)
                                PointView(point: grid[x, offset - y], grid: $grid, selectedPoint: $selectedPoint, proxy: proxy, isEdge: isEdge) { translation in
                                    didMovePoint(x, offset - y, translation)
                                }
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }

        struct PointView: View {
            @State var point: MeshColor
            @Binding var grid: MeshColorGrid
            @Binding var selectedPoint: MeshColor?
            let proxy: GeometryProxy
            let isEdge: Bool
            var didMove: (_ translation: CGSize) -> Void

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

                                point.location.x = Float(width) + point.startLocation.x
                                point.location.y = -Float(height) + point.startLocation.y

                                let offsetWidth = -proxy.size.width / CGFloat(grid.width)
                                let offsetX = min(abs(offsetWidth) - 45, max(offsetWidth + 45, location.x))

                                let offsetHeight = -proxy.size.height / CGFloat(grid.height)
                                let offsetY = min(abs(offsetHeight) - 45, max(offsetHeight + 45, location.y))
                                offset = CGSize(width: offsetX, height: offsetY)

                                didMove(CGSize(width: width, height: 1 - height))
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
