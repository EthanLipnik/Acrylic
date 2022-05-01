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
        let config = GenerateMeshGradientIntent()
        config.colorPalette = .blue
        let mesh = Self.generateRandomMesh(configuration: config)
        return MeshEntry(date: Date(),
                  mesh: mesh,
                  imageData: mesh.render(resolution: CGSize(width: 512, height: 512)).pngData(),
                  configuration: config)
    }
    
    func getSnapshot(for configuration: GenerateMeshGradientIntent, in context: Context, completion: @escaping (MeshEntry) -> ()) {
        let mesh = Self.generateRandomMesh(configuration: configuration)
        let entry = MeshEntry(date: Date(),
                  mesh: mesh,
                  imageData: mesh.render(resolution: CGSize(width: 512, height: 512)).pngData(),
                  configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: GenerateMeshGradientIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        DispatchQueue.global(qos: .background).async {
            let configuration = TelemetryManagerConfiguration(
                appID: "B278B666-F5F1-4014-882C-5403DA338EE5")
            TelemetryManager.initialize(with: configuration)
            
            TelemetryManager.send("meshGenerated")
        }
        
        var entries: [MeshEntry] = []

        // Generate a timeline consisting of five entries a 30 minutes apart, starting from the current date.
        let currentDate = Date()
        for minuteOffset in 0..<30 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            
            let mesh = Self.generateRandomMesh(configuration: configuration)
            let entry = MeshEntry(date: entryDate,
                      mesh: mesh,
                      imageData: mesh.render(resolution: CGSize(width: 512, height: 512)).pngData(),
                      configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
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
    let mesh: MeshService
    let imageData: Data?
    let configuration: GenerateMeshGradientIntent
}

struct AcrylicWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        Group {
            if let imageData = entry.imageData, let uiImage = UIImage(data: imageData) {
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
    }
}

@main
struct AcrylicWidget: Widget {
    let kind: String = "AcrylicWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: GenerateMeshGradientIntent.self, provider: Provider()) { entry in
            AcrylicWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Mesh Gradient")
        .description("Generate a random mesh gradient from a widget.")
    }
}

struct AcrylicWidget_Previews: PreviewProvider {
    static var previews: some View {
        let config = GenerateMeshGradientIntent()
        config.colorPalette = .random
        let mesh = Provider.generateRandomMesh(configuration: config)
        let entry = MeshEntry(date: Date(),
                              mesh: mesh,
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
