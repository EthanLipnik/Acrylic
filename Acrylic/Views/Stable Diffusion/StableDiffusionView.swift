//
//  StableDiffusionView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/14/22.
//

// import MapleDiffusion
import Combine
import SwiftUI
import UniformTypeIdentifiers

struct StableDiffusionView: View {
    @StateObject var mapleDiffusion = MapleDiffusion(
        saveMemoryButBeSlower: false,
        modelFolder: FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("StableDiffusion/bins")
    )

    let dispatchQueue = DispatchQueue(label: "Generation")
    @State private var steps: Float = 20
    @State private var image: Image?
    @State private var prompt: String = ""
    @State private var negativePrompt: String = ""
    @State private var guidanceScale: Float = 7.5
    @State private var running: Bool = false
    @State private var progressProp: Float = 1
    @State private var progressStage: String = "Ready"
    @State private var seed: Int = 42
    @State private var photoToSave: URL? = nil
    
    @State private var imageFile: ImageDocument?
    @State private var shouldExportFile: Bool = false

    @State var bin = Set<AnyCancellable>()

    func generate() throws {
        guard !prompt.isEmpty else { return }
        
        running = true
        progressStage = ""
        progressProp = 0

        try mapleDiffusion.generate(prompt: prompt, negativePrompt: negativePrompt, seed: seed, steps: Int(steps), guidanceScale: guidanceScale)

            .sink(receiveCompletion: { _ in
                      running = false
                  },
                  receiveValue: { result in
                      if let i = result.image {
                          image = Image(i, scale: 1, label: Text("Generated Image"))

                          if result.stage == "Cooling down..." {
                              let url = FileManager.default.temporaryDirectory.appendingPathComponent("Image.png")
                              print(url.path)
                              if let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) {
                                  CGImageDestinationAddImage(destination, i, nil)
                                  CGImageDestinationFinalize(destination)
                                  
                                  if let image = NSImage(contentsOfFile: url.path()) {
                                      imageFile = .init(image: image)
                                      photoToSave = url
                                  }
                              }
                          }
                      }
                      print("stage", result.stage)
                      progressStage = result.stage
                      progressProp = Float(result.progress)
                  }).store(in: &bin)
    }

    var body: some View {
        VStack {
            HStack(spacing: 20) {
                if !running {
                    VStack(alignment: .leading) {
                        Text("Prompt")
                            .bold()
                        TextEditor(text: $prompt)
                            .overlay(alignment: .topLeading) {
                                if prompt.isEmpty {
                                    Text("eg) a photo of a gorilla walking in Time Square")
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 8)
                                }
                            }
                            .padding()
                            .background {
                                RoundedRectangle(
                                    cornerRadius: 10,
                                    style: .continuous
                                )
                                .fill(Color(.textBackgroundColor))
                            }
                            .aspectRatio(1 / 1, contentMode: .fit)
                    }
                    .transition(.blur)
                }

                VStack(alignment: .leading) {
                    Text("Render")
                        .bold()
                    Group {
                        if let image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .frame(
                                    idealWidth: mapleDiffusion.width.doubleValue,
                                    idealHeight: mapleDiffusion.height.doubleValue
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.secondary)
                                .aspectRatio(1.0, contentMode: .fit)
                                .frame(
                                    idealWidth: mapleDiffusion.width.doubleValue,
                                    idealHeight: mapleDiffusion.height.doubleValue
                                )
                        }
                    }
                    .shadow(radius: 30, y: 8)
                }
            }
            .padding(.bottom)

            Spacer()

            HStack {
                Text("Negative Prompt").bold()
                TextField("What you don't want", text: $negativePrompt)
                    .textFieldStyle(.roundedBorder)
            }
            .disabled(running)

            HStack {
                HStack {
                    HStack {
                        Text("Scale").bold()
                        Text(String(format: "%.1f", guidanceScale))
                            .monospacedDigit()
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 70, alignment: .leading)
                    Slider(value: $guidanceScale, in: 1 ... 20)
                }
                HStack {
                    Text("Seed").bold()
                    TextField("", value: $seed, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 180)
                    Button {
                        seed = Int.random(in: 1 ... Int.max)
                    } label: {
                        Image(systemName: "arrow.clockwise.circle.fill")
                    }
                    .buttonStyle(.plain)
                }
            }
            .disabled(running)
            
            HStack {
                HStack {
                    Text("Steps")
                        .bold()
                    Text("\(Int(steps))")
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                }
                .frame(width: 70, alignment: .leading)
                Slider(value: $steps, in: 5 ... 150)
            }
            .disabled(running)

            if running {
                Spacer()

                ProgressView(progressStage, value: progressProp, total: 1)
                    .foregroundColor(.secondary)
            }
        }
        .animation(.spring(), value: running)
        .padding()
        .toolbar {
            ToolbarItem {
                if let photoToSave,
                   let imageFile = imageFile
                {
                    Menu {
                        ShareLink("Share", item: photoToSave, preview: SharePreview("Render", image: Image(nsImage: imageFile.image)))
                        Button("Export") {
                            shouldExportFile.toggle()
                        }
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .fileExporter(isPresented: $shouldExportFile, document: imageFile, contentType: .png, defaultFilename: "Render.png") { result in
                        switch result {
                        case .success(let url):
                            try? FileManager.default.removeItem(at: photoToSave)
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button {
                    do {
                        try generate()
                    } catch {
                        print(error)
                    }
                } label: {
                    Label("Generate", systemImage: running ? "stop.fill" : "play.fill")
                }
                .disabled(running || !mapleDiffusion.isModelLoaded || prompt.isEmpty)
            }
        }
        .onReceive(mapleDiffusion.state) { newState in
            switch newState {
            case .notStarted:
                print("Model not started")
            case let .modelIsLoading(progress: progress):
                running = true
                print("model loading", progress.message, progress.fractionCompleted)
                progressProp = Float(progress.fractionCompleted)
                progressStage = progress.message
            case .ready:
                print("model ready")
                running = false
            }
        }
    }
}

struct StableDiffusionView_Previews: PreviewProvider {
    static var previews: some View {
        StableDiffusionView()
    }
}
