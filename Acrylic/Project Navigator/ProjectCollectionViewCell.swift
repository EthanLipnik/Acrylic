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
    
    
    var document: Document? = nil {
        didSet {
            guard let document = document, let fileUrl = document.fileUrl else {
                
                self.imageView.image = nil
                self.iCloudBadge.isHidden = true
                self.fileNameLabel.text = "–"
                return
            }
            
            if let previewImage = UIImage(contentsOfFile: fileUrl.appendingPathComponent("PreviewImage").path) {
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
            fileNameLabel.text = document.fileUrl?.deletingPathExtension().lastPathComponent
        }
    }
    
    lazy var imageContainerView: UIView = {
        let containerView = UIView()
        
        containerView.layer.cornerRadius = 20
        containerView.layer.cornerCurve = .continuous
        
        containerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        containerView.layer.shadowRadius = 15
        containerView.layer.shadowOpacity = 0.4
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        return containerView
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFill
        
        imageView.backgroundColor = randomColor(hue: .random, luminosity: .bright)
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.cornerCurve = .continuous
        
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
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
        
        imageView.isHidden = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    lazy var fileNameLabel: UILabel = {
        let label = UILabel()
        
        label.text = "–"
        label.font = UIFont.preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
#if targetEnvironment(macCatalyst)
    var doubleClickAction: () -> Void = {}
    @objc func doubleClick() { doubleClickAction() }
#endif
    var singleClickAction: () -> Void = {}
    @objc func singleClick() { singleClickAction() }
    
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
        contentView.addSubview(imageContainerView)
        contentView.addSubview(iCloudBadge)
        contentView.addSubview(fileNameLabel)
        
        imageContainerView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageContainerView.topAnchor.constraint(equalTo: topAnchor),
            imageContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageContainerView.heightAnchor.constraint(equalTo: imageContainerView.widthAnchor),
            
            iCloudBadge.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor, constant: -10),
            iCloudBadge.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: -10),
            iCloudBadge.widthAnchor.constraint(equalToConstant: 32),
            iCloudBadge.heightAnchor.constraint(equalTo: imageContainerView.widthAnchor),
            
            fileNameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            fileNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            fileNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        let pointerInteraction = UIPointerInteraction()
        addInteraction(pointerInteraction)
        
#if targetEnvironment(macCatalyst)
        let doubleClickGesture = UITapGestureRecognizer(target: self, action: #selector(doubleClick))
        doubleClickGesture.numberOfTapsRequired = 2
        doubleClickGesture.delegate = self
        addGestureRecognizer(doubleClickGesture)
#endif
        
        let singleClickGesture = UITapGestureRecognizer(target: self, action: #selector(singleClick))
        singleClickGesture.numberOfTapsRequired = 1
        singleClickGesture.delegate = self
        addGestureRecognizer(singleClickGesture)
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
