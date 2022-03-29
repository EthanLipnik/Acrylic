//
//  ProjectCollectionViewCell.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/27/22.
//

import UIKit
import RandomColor
import QuickLookThumbnailing

class ProjectCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    static let reuseIdentifer = String(describing: ProjectCollectionViewCell.self)
    
    
    var document: ProjectNavigatorViewController.Document? = nil {
        didSet {
            guard let document = document, let fileUrl = document.fileUrl else {
                
                self.imageView.image = nil
                self.iCloudBadge.isHidden = true
                return
            }
            
            if let previewImage = UIImage(contentsOfFile: fileUrl.appendingPathComponent("PreviewImage.heic").path) {
                self.imageView.image = previewImage
            } else {
                DispatchQueue.global(qos: .userInitiated).async {
                    let request = QLThumbnailGenerator
                        .Request(fileAt: fileUrl, size: CGSize(width: 512, height: 512), scale: 1,
                                 representationTypes: .thumbnail)
                    
                    QLThumbnailGenerator.shared.generateRepresentations(for: request) { (thumbnail, type, error) in
                        DispatchQueue.main.async { [weak self] in
                            if let error = error {
                                print(error)
                            } else if let thumbnail = thumbnail {
                                self?.imageView.image = thumbnail.uiImage
                            }
                        }
                    }
                }
            }
            
            iCloudBadge.isHidden = fileUrl.pathExtension != "icloud"
        }
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        imageView.backgroundColor = randomColor(hue: .random, luminosity: .bright)
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.cornerCurve = .continuous
        
        return imageView
    }()
    
    lazy var iCloudBadge: UIImageView = {
        var symbolConfig: UIImage.SymbolConfiguration
        if #available(iOS 15.0, macOS 12.0, *) {
            symbolConfig = UIImage.SymbolConfiguration(hierarchicalColor: UIColor.systemFill)
        } else {
            symbolConfig = UIImage.SymbolConfiguration(weight: UIImage.SymbolWeight.bold)
        }
        let imageView = UIImageView(image: UIImage(systemName: "icloud.circle.fill", withConfiguration: symbolConfig))
        
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        
        imageView.isHidden = true
        
        return imageView
    }()
    
#if targetEnvironment(macCatalyst)
    var doubleClickAction: () -> Void = {}
    var singleClickAction: () -> Void = {}
    @objc func doubleClick() { doubleClickAction() }
    @objc func singleClick() { singleClickAction() }
#endif
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderColor = UIColor.link.cgColor
                layer.borderWidth = 2
            } else {
                layer.borderColor = nil
                layer.borderWidth = 0
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        contentView.addSubview(imageView)
        contentView.addSubview(iCloudBadge)
        imageView.frame = contentView.bounds
        
        iCloudBadge.frame = CGRect(x: contentView.bounds.width - 32 - 10, y: contentView.bounds.height - 32 - 10, width: 32, height: 32)
        
        layer.cornerRadius = 20
        layer.cornerCurve = .continuous
        
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowRadius = 15
        layer.shadowOpacity = 0.4
        
        let pointerInteraction = UIPointerInteraction()
        addInteraction(pointerInteraction)
        
#if targetEnvironment(macCatalyst)
        let doubleClickGesture = UITapGestureRecognizer(target: self, action: #selector(doubleClick))
        doubleClickGesture.numberOfTapsRequired = 2
        doubleClickGesture.delegate = self
        addGestureRecognizer(doubleClickGesture)
        
        let singleClickGesture = UITapGestureRecognizer(target: self, action: #selector(singleClick))
        singleClickGesture.numberOfTapsRequired = 1
        singleClickGesture.delegate = self
        addGestureRecognizer(singleClickGesture)
#endif
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        iCloudBadge.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 15).cgPath
        iCloudBadge.frame = CGRect(x: contentView.bounds.width - 32 - 10, y: contentView.bounds.height - 32 - 10, width: 32, height: 32)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
