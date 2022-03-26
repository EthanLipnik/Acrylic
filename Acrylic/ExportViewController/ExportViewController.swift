//
//  ExportViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/21/22.
//

import UIKit
import SwiftUI
import Blackbird
import Combine

class ExportViewController: UIViewController {
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    lazy var blackbirdView: UIBlackbirdView = {
        let blackbirdView = UIBlackbirdView()
        
        blackbirdView.backgroundColor = UIColor.secondarySystemFill
        blackbirdView.layer.cornerRadius = 10
        blackbirdView.layer.cornerCurve = .continuous
        blackbirdView.layer.masksToBounds = true
        
        blackbirdView.image = exportService.baseImage
        
        return blackbirdView
    }()
    
    lazy var exportOptionsView: UIView = {
        let viewController = UIHostingController(rootView: ExportOptionsView().environmentObject(exportService))
        
        viewController.didMove(toParent: self)
        
        return viewController.view
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    
    let exportService: ExportService
    
    init(renderImage: UIImage) {
        self.exportService = ExportService(renderImage: renderImage)
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
        stackView.addArrangedSubview(exportOptionsView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            blackbirdView.heightAnchor.constraint(equalTo: blackbirdView.widthAnchor)
        ])
        
        exportService.$filteredImage
            .sink { [weak self] image in
                self?.blackbirdView.image = image
            }
            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.blackbirdView.image = self?.exportService.baseImage
            self?.blackbirdView.image = self?.exportService.baseImage
        }
    }
    
    @objc func export() {
        let ciImage = exportService.filteredImage ?? exportService.baseImage
        let cgImage = Blackbird.shared.context.createCGImage(ciImage, from: exportService.baseImage.extent)!
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
        
//        if traitCollection.horizontalSizeClass == .regular {
        if UIDevice.current.userInterfaceIdiom == .mac {
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
