//
//  ExportView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/26/22.
//

import SwiftUI

struct ExportView: View {
    @StateObject var exportService: ExportService
    
    init(renderImage: UIImage) {
        self._exportService = .init(wrappedValue: ExportService(renderImage: renderImage))
    }
    
    var body: some View {
        HStack(spacing: 20) {
            ExportViewControllerView()
                .aspectRatio(CGFloat(exportService.resolution.width / exportService.resolution.height), contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                .shadow(radius: 15, y: 8)
                .environmentObject(exportService)
            ExportOptionsView()
                .environmentObject(exportService)
        }
        .animation(.spring(), value: exportService.resolution.width)
        .animation(.spring(), value: exportService.resolution.height)
        .padding()
    }
}

struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportView(renderImage: UIImage())
    }
}
