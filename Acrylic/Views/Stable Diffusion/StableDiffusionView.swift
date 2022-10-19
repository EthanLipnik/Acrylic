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
import Vision

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
    @State private var seed: Int = Int.random(in: 1 ... Int.max)
    @State private var photoToSave: URL? = nil
    
    @State private var isShowingOptions: Bool = false
    
    @State private var isExporting: Bool = false
    @State private var imageFile: ImageDocument?
    @State private var shouldExportFile: Bool = false
    
    @State private var shouldUpscale: Bool = false
    
    @State var bin = Set<AnyCancellable>()
    
    let upscaleModelDestination = FileManager.default.urls(
        for: .applicationSupportDirectory,
        in: .userDomainMask
    )[0].appendingPathComponent("CoreML/realesrgan512.mlmodel")
    
    let intFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.alwaysShowsDecimalSeparator = false
        numberFormatter.generatesDecimalNumbers = false
        return numberFormatter
    }()
    
    let doubleFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 1
        return numberFormatter
    }()
    
    func generate() throws {
        guard !prompt.isEmpty,
              steps > 0,
              guidanceScale > 0
        else { return }
        
        running = true
        progressStage = ""
        progressProp = 0
        
        photoToSave = nil
        imageFile = nil
        image = nil
        
        try mapleDiffusion.generate(prompt: prompt, negativePrompt: negativePrompt, seed: seed, steps: Int(steps), guidanceScale: guidanceScale)
        
            .sink(receiveCompletion: { _ in
                running = false
            }, receiveValue: { result in
                if var i = result.image {
                    do {
                        if shouldUpscale {
                            i = try upscale(i)
                        }
                        
                        image = Image(i, scale: 1, label: Text("Generated Image"))
                        
                        if result.stage == "Cooling down..." {
                            let url = FileManager.default.temporaryDirectory.appendingPathComponent("Image.png")
                            
                            if let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) {
                                CGImageDestinationAddImage(destination, i, nil)
                                CGImageDestinationFinalize(destination)
                                
                                if let image = NSImage(contentsOfFile: url.path()) {
                                    imageFile = .init(image: image)
                                    photoToSave = url
                                }
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
                print("stage", result.stage)
                progressStage = result.stage
                progressProp = Float(result.progress)
            }).store(in: &bin)
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 20) {
                if !running {
                    VStack(alignment: .leading) {
                        Text("Prompt")
                            .bold()
                        VStack {
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
                            
                            HStack {
                                Text("Negative Prompt").bold()
                                TextField("What you don't want", text: $negativePrompt)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        .aspectRatio(1/1, contentMode: .fit)
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
                                .frame(
                                    idealWidth: mapleDiffusion.width.doubleValue,
                                    idealHeight: mapleDiffusion.height.doubleValue
                                )
                                .id(progressProp)
                        } else {
                            Rectangle()
                                .fill(.secondary)
                                .aspectRatio(1.0, contentMode: .fit)
                                .frame(
                                    idealWidth: mapleDiffusion.width.doubleValue,
                                    idealHeight: mapleDiffusion.height.doubleValue
                                )
                        }
                    }
                    .transition(.blur(scale: 1, scaleAnimation: .linear(duration: 0)).animation(.easeInOut))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .shadow(radius: 30, y: 8)
                }
            }
            .padding(.bottom)
            
            if running {
                Spacer()
                
                ProgressView(progressStage, value: min(1, progressProp), total: 1)
                    .foregroundColor(.secondary)
            }
        }
        .animation(.spring(), value: running)
        .padding()
        .toolbar {
            
            ToolbarItem(placement: .navigation) {
                if let photoToSave,
                   let imageFile = imageFile
                {
                    Button {
                        isExporting.toggle()
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                    .popover(isPresented: $isExporting) {
                        HStack(spacing: 10) {
                            ShareLink(item: photoToSave, preview: SharePreview("Render", image: Image(nsImage: imageFile.image))) {
                                Image(systemName: "arrowshape.turn.up.right.fill")
                                    .aspectRatio(1/1, contentMode: .fit)
                                    .padding(20)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(Color.white.opacity(0.4).blendMode(.overlay))
                                    }
                            }
                            .buttonStyle(.plain)
                            
                            Button {
                                shouldExportFile.toggle()
                            } label: {
                                Image(systemName: "doc.fill")
                                    .aspectRatio(1/1, contentMode: .fit)
                                    .padding(20)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(Color.white.opacity(0.4).blendMode(.overlay))
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(10)
                    }
                    .fileExporter(isPresented: $shouldExportFile, document: imageFile, contentType: .png, defaultFilename: "Render.png") { result in
                        switch result {
                        case .success:
                            try? FileManager.default.removeItem(at: photoToSave)
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            }
            
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    isShowingOptions.toggle()
                } label: {
                    Label("Options", systemImage: "ellipsis.rectangle")
                }
                .popover(isPresented: $isShowingOptions) {
                    Form {
                        HStack {
                            Slider(value: $guidanceScale, in: 1 ... 20) {
                                HStack {
                                    Text("Guidance Scale")
                                    Text(String(format: "%.1f", guidanceScale))
                                        .monospacedDigit()
                                        .foregroundColor(.secondary)
                                        .frame(width: 40)
                                }
                            }
                            Button {
                                withAnimation {
                                    guidanceScale = 7.5
                                }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                        
                        HStack {
                            Slider(value: $steps, in: 5 ... 150) {
                                HStack {
                                    Text("Steps")
                                    Text("\(Int(steps))")
                                        .monospacedDigit()
                                        .foregroundColor(.secondary)
                                        .frame(width: 40)
                                }
                            }
                            
                            Button {
                                withAnimation {
                                    steps = 20
                                }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                        
                        Toggle("Super Resolution (4x)", isOn: $shouldUpscale)
                            .toggleStyle(.switch)
                            .disabled(!FileManager.default.fileExists(atPath: upscaleModelDestination.path(percentEncoded: false)))
                            .onAppear {
                                shouldUpscale = FileManager.default.fileExists(atPath: upscaleModelDestination.path(percentEncoded: false))
                            }
                        
                        Toggle("Conserve Memory", isOn: $mapleDiffusion.saveMemory)
                            .toggleStyle(.switch)
                    }
                    .frame(width: 300)
                    .padding()
                    .disabled(running)
                }
                
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
    
    func upscale(_ image: CGImage) throws -> CGImage {
        let model = try MLModel(contentsOf: upscaleModelDestination, configuration: MLModelConfiguration())
        guard let model = try? VNCoreMLModel(for: model),
              let pixelBuffer = image.pixelBuffer()
        else { throw MLModelError(.generic) }
        
        let coreMLRequest = VNCoreMLRequest(model: model)
        coreMLRequest.imageCropAndScaleOption = .scaleFill
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([coreMLRequest])
        
        guard let result = coreMLRequest.results?.first as? VNPixelBufferObservation else { throw MLModelError(.generic) }
        
        guard let image = CGImage.create(pixelBuffer: result.pixelBuffer) else { throw MLModelError(.generic) }
        return image
    }
}

struct StableDiffusionView_Previews: PreviewProvider {
    static var previews: some View {
        StableDiffusionView()
    }
}
