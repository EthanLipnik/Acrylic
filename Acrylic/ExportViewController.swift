//
//  ExportViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/21/22.
//

import UIKit
import SwiftUI
import Blackbird

class ExportViewController: UIViewController {
    let renderImage: UIImage
    
    lazy var baseImage: CIImage = {
        return CIImage(image: renderImage)!
    }()
    lazy var filteredImage: CIImage? = nil
    
    lazy var blackbirdView: UIBlackbirdView = {
        let blackbirdView = UIBlackbirdView()
        
        blackbirdView.backgroundColor = UIColor.secondarySystemFill
        blackbirdView.layer.cornerRadius = 10
        blackbirdView.layer.cornerCurve = .continuous
        blackbirdView.layer.masksToBounds = true
        
        blackbirdView.image = baseImage
        
        blackbirdView.translatesAutoresizingMaskIntoConstraints = false
        
        return blackbirdView
    }()
    
    lazy var blurSlider: UISlider = {
        let slider = UISlider()
        
        slider.maximumValue = 200
        
        slider.addTarget(self, action: #selector(blurDidChange(_:)), for: .valueChanged)
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        return slider
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(configuration: .bordered())
        button.setTitle("Cancel", for: .normal)
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    lazy var exportButton: UIButton = {
        let button = UIButton(configuration: .borderedProminent())
        button.setTitle("Export...", for: .normal)
        button.addTarget(self, action: #selector(export), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    lazy var blur: Float = 0
    
    init(renderImage: UIImage) {
        self.renderImage = renderImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.systemBackground
        
        view.addSubview(blackbirdView)
        view.addSubview(blurSlider)
        view.addSubview(exportButton)
        view.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            blackbirdView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            blackbirdView.heightAnchor.constraint(equalTo: blackbirdView.widthAnchor),
            blackbirdView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            blackbirdView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            
            blurSlider.topAnchor.constraint(equalTo: blackbirdView.bottomAnchor, constant: 20),
            blurSlider.leadingAnchor.constraint(equalTo: blackbirdView.leadingAnchor),
            blurSlider.trailingAnchor.constraint(equalTo: blackbirdView.trailingAnchor),
            blurSlider.bottomAnchor.constraint(lessThanOrEqualTo: exportButton.topAnchor),
            
            exportButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            exportButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            cancelButton.bottomAnchor.constraint(equalTo: exportButton.bottomAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.blackbirdView.image = self?.baseImage
            self?.blackbirdView.image = self?.baseImage
        }
    }
    
    @objc func blurDidChange(_ sender: UISlider) {
        let value = sender.value
        
        blur = value
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.applyFilters()
        }
    }
    
    func applyFilters() {
        let image = baseImage
            .clampedToExtent()
            .applyingFilter(.gaussian, radius: NSNumber(value: blur))
        
        self.filteredImage = image
        
        DispatchQueue.main.async { [weak self] in
            self?.blackbirdView.image = image
        }
    }
    
    @objc func export() {
        let ciImage = filteredImage ?? baseImage
        let cgImage = Blackbird.shared.context.createCGImage(ciImage, from: baseImage.extent)!
        let image = UIImage(cgImage: cgImage)
        
        let data = image.pngData()!
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Mesh.png")
        try! data.write(to: url)
        
#if targetEnvironment(macCatalyst)
        let documentExporter = UIDocumentPickerViewController(forExporting: [url])
        documentExporter.delegate = self
        self.present(documentExporter, animated: true)
#else
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceRect = exportButton.bounds
        activityController.popoverPresentationController?.sourceView = exportButton
        self.present(activityController, animated: true)
#endif
    }
}

extension ExportViewController: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        self.dismiss(animated: true)
    }
}
