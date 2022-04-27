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
    
    lazy var blackbirdView: UIBlackbirdView = {
        let blackbirdView = UIBlackbirdView()
        
        blackbirdView.backgroundColor = UIColor.systemBackground
        
        blackbirdView.translatesAutoresizingMaskIntoConstraints = false
        
        blackbirdView.image = exportService.previewImage ?? exportService.baseImage
        
        return blackbirdView
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    
    var exportService: ExportService
    
    init(exportService: ExportService) {
        self.exportService = exportService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.systemBackground
        
        view.addSubview(blackbirdView)
        
        NSLayoutConstraint.activate([
            blackbirdView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blackbirdView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blackbirdView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blackbirdView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        
        exportService.$previewImage
            .sink { [weak self] image in
                self?.blackbirdView.image = image ?? self?.exportService.baseImage
                self?.blackbirdView.draw()
            }
            .store(in: &cancellables)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        blackbirdView.draw()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        view.window?.windowScene?.requestReview()
    }
}

extension ExportViewController: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        self.dismiss(animated: true)
    }
}

struct ExportViewControllerView: UIViewControllerRepresentable {
    @EnvironmentObject var exportService: ExportService
    
    func makeUIViewController(context: Context) -> ExportViewController {
        return ExportViewController(exportService: exportService)
    }
    
    func updateUIViewController(_ uiViewController: ExportViewController, context: Context) {
        uiViewController.exportService = exportService
    }
}
