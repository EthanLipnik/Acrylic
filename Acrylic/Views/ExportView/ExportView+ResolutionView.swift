//
//  ExportView+ResolutionView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/25/22.
//

import Foundation
import SwiftUI

extension ExportView {
    struct ResolutionView: View {
        @EnvironmentObject var exportService: ExportService
        
        struct Resolution: Hashable, Identifiable {
            var id: String {
                return title
            }
            
            var title: String
            var size: CGFloat
        }
        
        struct AspectRatio: Hashable, Identifiable {
            var id: String {
                return title
            }
            
            var title: String
            var image: String
            var multiplier: CGFloat
            
            var alternateTitle: String? = nil
            var alternateImage: String? = nil
            var alternateMultiplier: CGFloat? = nil
        }
        
        let resolutions: [Resolution] = [
            .init(title: "1k", size: 1024),
            .init(title: "2k", size: 2048),
            .init(title: "4k", size: 4096),
            .init(title: "5k", size: 5120),
            .init(title: "8k", size: 8192),
            .init(title: "10k", size: 10240)
        ].filter({ UIDevice.current.userInterfaceIdiom == .mac || $0.size <= 4096 })
        @State private var selectedResolution: Resolution = .init(title: "1k", size: 1024)
        
        let aspectRatios: [AspectRatio] = [
            .init(title: "1:1",
                  image: "square",
                  multiplier: 1),
            .init(title: "16:9",
                  image: "iphone.homebutton.landscape",
                  multiplier: 16/9,
                  alternateTitle: "9:16",
                  alternateImage: "iphone.homebutton",
                  alternateMultiplier: 9/16),
            .init(title: "2:1",
                  image: "iphone.landscape",
                  multiplier: 2/1,
                  alternateTitle: "1:2",
                  alternateImage: "iphone",
                  alternateMultiplier: 1/2),
            .init(title: "4:3",
                  image: "ipad.landscape",
                  multiplier: 4/3,
                  alternateTitle: "3:4",
                  alternateImage: "ipad",
                  alternateMultiplier: 3/4)
        ]
        @State private var selectedAspectRatio: AspectRatio = .init(title: "1:1", image: "square", multiplier: 1)
        
        var body: some View {
            VStack {
                Text("Quality")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Picker(selection: $selectedResolution) {
                    ForEach(resolutions) {
                        Text($0.title
                             + " (\($0.size)x\($0.size))"
                             + (($0.size > 2048 && UIDevice.current.userInterfaceIdiom != .mac) ? " [Experimental]" : ""))
                            .tag($0)
                    }
                } label: {
                    Text("Resolution:")
                        .frame(width: 110, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .onChange(of: selectedResolution) { newValue in
                    exportService.resolution = (CGFloat(newValue.size),
                                                CGFloat(newValue.size) * selectedAspectRatio.multiplier)
                }
                
                aspectRatioPicker
            }
        }
        
        var aspectRatioPicker: some View {
            Menu {
                ForEach(aspectRatios) { ratio in
                    if let alternateTitle = ratio.alternateTitle,
                       let alternateImage = ratio.alternateImage,
                       let alternateMultipler = ratio.alternateMultiplier {
                        Menu {
                            Picker(selection: $selectedAspectRatio) {
                                Text("Horizontal")
                                    .tag(AspectRatio(title: ratio.title, image: ratio.image, multiplier: alternateMultipler))
                                
                                Text("Vertical")
                                    .tag(AspectRatio(title: alternateTitle, image: alternateImage, multiplier: ratio.multiplier))
                            } label: {
                                Text("Apect Ratio")
                            }
                        } label: {
                            Label(ratio.title, systemImage: ratio.image)
                        }
                    } else {
                        Button(ratio.title) {
                            selectedAspectRatio = ratio
                        }
                    }
                }
            } label: {
                Label(selectedAspectRatio.title, systemImage: selectedAspectRatio.image)
                    .frame(width: 110, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onChange(of: selectedAspectRatio) { newValue in
                exportService.resolution = (CGFloat(selectedResolution.size),
                                            CGFloat(selectedResolution.size) * newValue.multiplier)
            }
        }
    }
}
