//
//  ExportView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/26/22.
//

import SwiftUI
import SceneKit

struct ExportView: View {
    @StateObject var exportService: ExportService

    init(document: Document) {
        self._exportService = .init(wrappedValue: ExportService(document: document))
    }

    var body: some View {
        Stack(spacing: 20) {
            ExportViewControllerView()
                .aspectRatio(CGFloat(exportService.resolution.width / exportService.resolution.height), contentMode: .fit)
                .overlay(
                    exportService.isProcessing ?
                    ZStack {
                        VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
                        ProgressView().progressViewStyle(.circular)
                    } : nil
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(radius: 15, y: 8)
                .environmentObject(exportService)
            ExportOptionsView()
                .environmentObject(exportService)
        }
        .animation(.spring(), value: exportService.resolution.width)
        .animation(.spring(), value: exportService.resolution.height)
        .padding()
    }

#if targetEnvironment(macCatalyst)
    typealias Stack = HStack
#else
    typealias Stack = VStack
#endif
}

struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportView(document: .mesh(.init()))
    }
}
