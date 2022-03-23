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
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    lazy var optionsStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.spacing = 10
        
        return stackView
    }()
    
    lazy var blackbirdView: UIBlackbirdView = {
        let blackbirdView = UIBlackbirdView()
        
        blackbirdView.backgroundColor = UIColor.secondarySystemFill
        blackbirdView.layer.cornerRadius = 10
        blackbirdView.layer.cornerCurve = .continuous
        blackbirdView.layer.masksToBounds = true
        
        blackbirdView.image = baseImage
        
        return blackbirdView
    }()
    
    lazy var blurSlider: SliderView = {
        return SliderView(title: "Blur", valueChanged: blurDidChange(_:))
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
    
    lazy var buttonsView = UIView()
    
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
        
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(blackbirdView)
        stackView.addArrangedSubview(optionsStackView)
        
        optionsStackView.addArrangedSubview(blurSlider)
        optionsStackView.addArrangedSubview(UIView())
        optionsStackView.addArrangedSubview(buttonsView)
        
        buttonsView.addSubview(exportButton)
        buttonsView.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            blackbirdView.heightAnchor.constraint(equalTo: blackbirdView.widthAnchor),
            
            exportButton.topAnchor.constraint(equalTo: buttonsView.topAnchor),
            exportButton.bottomAnchor.constraint(equalTo: buttonsView.safeAreaLayoutGuide.bottomAnchor),
            exportButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: exportButton.topAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: exportButton.bottomAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.blackbirdView.image = self?.baseImage
            self?.blackbirdView.image = self?.baseImage
        }
    }
    
    @objc func blurDidChange(_ value: Float) {
        blur = value * 100
        
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if traitCollection.horizontalSizeClass == .regular {
            stackView.axis = .horizontal
            preferredContentSize = CGSize(width: 1024, height: 512)
        } else {
            stackView.axis = .vertical
            preferredContentSize = .zero
        }
    }
    
    class SliderView: UIView {
        let title: String
        let valueChanged: (Float) -> Void
        
        init(title: String, valueChanged: @escaping (Float) -> Void) {
            self.title = title
            self.valueChanged = valueChanged
            super.init(frame: .zero)
            setup()
        }
        
        override init(frame: CGRect) {
            fatalError()
        }
        
        required init?(coder: NSCoder) {
            fatalError()
        }
        
        private func setup() {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 4
            
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
            titleLabel.textAlignment = .left
            stackView.addArrangedSubview(titleLabel)
            
            let slider = UISlider()
            slider.addTarget(self, action: #selector(valueDidChange(_:)), for: .valueChanged)
            stackView.addArrangedSubview(slider)
            
            addSubview(stackView)
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
        
        @objc func valueDidChange(_ sender: UISlider) {
            valueChanged(sender.value)
        }
    }
}

extension ExportViewController: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        self.dismiss(animated: true)
    }
}
