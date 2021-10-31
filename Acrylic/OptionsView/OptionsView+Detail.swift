//
//  OptionsView+Detail.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/24/21.
//

import SwiftUI
import MeshKit

extension OptionsView {
    struct DetailsView: View {
        @EnvironmentObject var meshService: MeshService
        
        var withBackground: Bool = true
        
        var subdivsionsIntProxy: Binding<Double>{
            Binding<Double>(get: {
                //returns the score as a Double
                return Double(meshService.subdivsions)
            }, set: {
                //rounds the double to an Int
                meshService.subdivsions = Int($0)
            })
        }
        
        var widthIntProxy: Binding<Double>{
            Binding<Double>(get: {
                //returns the score as a Double
                return Double(meshService.width)
            }, set: {
                //rounds the double to an Int
                guard meshService.width != Int($0) else { return }
                let oldWidth = meshService.width
                meshService.width = Int($0)
                
                if oldWidth < Int($0) {
                    for x in oldWidth..<Int($0) {
                        for y in 0..<meshService.height {
                            let color = MeshNode.Color(point: (x, y), location: (Float(x), Float(y)), color: .white, tangent: (2, 2))
                            meshService.colors.append(color)
                        }
                    }
                } else {
                    let difference = oldWidth - Int($0)
                    var colors = meshService.colors
                    for i in 0..<difference {
                        let x = meshService.width - i
                        colors = colors.filter({ $0.point.x != x })
                    }
                    
                    meshService.colors = colors
                }
            })
        }
        
        var heightIntProxy: Binding<Double>{
            Binding<Double>(get: {
                //returns the score as a Double
                return Double(meshService.height)
            }, set: {
                //rounds the double to an Int
                guard meshService.height != Int($0) else { return }
                let oldHeight = meshService.height
                meshService.height = Int($0)
                
                if oldHeight < Int($0) {
                    for y in oldHeight..<Int($0) {
                        for x in 0..<meshService.width {
                            let color = MeshNode.Color(point: (x, y), location: (Float(x), Float(y)), color: .white, tangent: (2, 2))
                            meshService.colors.append(color)
                        }
                    }
                } else {
                    let difference = oldHeight - Int($0)
                    var colors = meshService.colors
                    for i in 0..<difference {
                        let y = meshService.height - i
                        colors = colors.filter({ $0.point.y != y })
                    }
                    
                    meshService.colors = colors
                }
            })
        }
        
        var body: some View {
            let scaleView = DetailView(title: "Points", systemImage: "circle.grid.3x3") {
                HStack {
                    Stepper(value: widthIntProxy, in: 3.0...6.0) {
                        Label("Width", systemImage: "arrow.left.arrow.right")
                    }
                    Text("\(meshService.width)")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(Color.secondary)
                }
                HStack {
                    Stepper(value: heightIntProxy, in: 3.0...6.0) {
                        Label("Vertical", systemImage: "arrow.up.arrow.down")
                    }
                    
                    Text("\(meshService.height)")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(Color.secondary)
                }
            }
            
            return DetailView(title: "Detail", systemImage: "sparkles", withBackground: withBackground) {
                VStack(spacing: 20) {
                    HStack {
                        Stepper(value: subdivsionsIntProxy, in: 4.0...36.0, step: 2.0) {
                            Label("Subdivsion", systemImage: "rectangle.split.3x3.fill")
                        }
                        Text("\(meshService.subdivsions)")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(Color.secondary)
                            .allowsTightening(true)
                            .minimumScaleFactor(0.8)
                    }
                    .animation(.spring(), value: meshService.subdivsions)
                    .contextMenu {
                        Button("Reset") {
                            withAnimation {
                                meshService.subdivsions = 18
                            }
                        }
                    }
                    
                    if UIDevice.current.userInterfaceIdiom == .mac {
                        scaleView
                    } else {
                        scaleView.view
                    }
                }
            }
        }
    }
}
