//
//  AcrylicWidget.swift
//  AcrylicWidget
//
//  Created by Ethan Lipnik on 5/1/22.
//

import WidgetKit
import SwiftUI
import Intents
import RandomColor
import TelemetryClient

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> MeshEntry {
        return MeshEntry(date: Date(),
                         imageData: UIImage(named: "Mesh")?.jpegData(compressionQuality: 0.8),
                         configuration: GenerateMeshGradientIntent())
    }
    
    func getSnapshot(for configuration: GenerateMeshGradientIntent, in context: Context, completion: @escaping (MeshEntry) -> ()) {
        DispatchQueue.global(qos: .background).async {
            let mesh = Self.generateRandomMesh(configuration: configuration)
            let entry = MeshEntry(date: Date(),
                                  imageData: mesh.render(resolution: CGSize(width: 256, height: 256)).pngData(),
                                  configuration: configuration)
            completion(entry)
        }
    }

    func getTimeline(for configuration: GenerateMeshGradientIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        DispatchQueue.global(qos: .background).async {
            let configuration = TelemetryManagerConfiguration(
                appID: "B278B666-F5F1-4014-882C-5403DA338EE5")
            TelemetryManager.initialize(with: configuration)
            
            TelemetryManager.send("meshGenerated")
        }
        
        DispatchQueue.global(qos: .background).async {
            // Generate a timeline consisting of three entries an hour apart, starting from the current date.
            let currentDate = Date()
            let dates: [Date] = (0..<3).compactMap({ Calendar.current.date(byAdding: .hour, value: $0, to: currentDate) })
            let entries: [MeshEntry] = dates.map { date in
                let mesh = Self.generateRandomMesh(configuration: configuration)
                let render = mesh.render(resolution: CGSize(width: 256, height: 256))
                let imageData: Data?
                
                if let jpeg = render.jpegData(compressionQuality: 0.8) {
                    imageData = jpeg
                } else {
                    imageData = render.pngData()
                }
                
                return MeshEntry(date: date,
                                 imageData: imageData,
                                 configuration: configuration)
            }
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
    
    static func generateRandomMesh(configuration: GenerateMeshGradientIntent = .init()) -> MeshService {
        let meshService = MeshService()
        meshService.width = configuration.width?.intValue ?? 3
        meshService.height = configuration.height?.intValue ?? 3
        meshService.generate(Palette: .hue(from: configuration.colorPalette),
                             luminosity: .luminosity(from: configuration.luminosity),
                             positionMultiplier: configuration.positionMultiplier?.floatValue ?? 0.5)
        
        return meshService
    }
}

struct MeshEntry: TimelineEntry {
    let date: Date
    let imageData: Data?
    let configuration: GenerateMeshGradientIntent
}

struct AcrylicWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        Group {
            if let imageData = entry.imageData,
                let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Text("Failed to generate mesh")
                    .lineLimit(0)
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .background(Image("Mesh").resizable().scaledToFill())
    }
}

@main
struct AcrylicWidget: Widget {
    let kind: String = "AcrylicWidget"
    
    private let supportedFamilies:[WidgetFamily] = {
        if #available(iOSApplicationExtension 15.0, *) {
            return [.systemSmall,
                    .systemMedium,
                    .systemLarge,
                    .systemExtraLarge]
        } else {
            return [.systemSmall,
                    .systemMedium,
                    .systemLarge]
        }
    }()
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: GenerateMeshGradientIntent.self, provider: Provider()) { entry in
            AcrylicWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Mesh Gradient")
        .description("Generate a random mesh gradient from a widget.")
        .supportedFamilies(supportedFamilies)
    }
}

struct AcrylicWidget_Previews: PreviewProvider {
    static var previews: some View {
        let config = GenerateMeshGradientIntent()
        config.colorPalette = .random
        let mesh = Provider.generateRandomMesh(configuration: config)
        let entry = MeshEntry(date: Date(),
                              imageData: mesh.render(resolution: CGSize(width: 512, height: 512)).pngData(),
                              configuration: config)
        
        return Group {
            AcrylicWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            AcrylicWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            AcrylicWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            
            if #available(iOS 15.0, *) {
                AcrylicWidgetEntryView(entry: entry)
                    .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
            }
        }
    }
}
