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
                self.fileNameLabel.text = "–"
                return
            }
            
            imageView.hero.id = fileUrl.path
            
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
                                let controller = UIDocumentInteractionController(url: fileUrl)
                                self?.imageView.image = controller.icons.first
                            } else if let thumbnail = thumbnail {
                                self?.imageView.image = thumbnail.uiImage
                            }
                        }
                    }
                }
            }
            
            var fileNameAttributedString = NSMutableAttributedString(string: fileUrl.deletingPathExtension().lastPathComponent)
            
            if fileUrl.pathExtension == "icloud" {
                fileNameAttributedString = .init(string: fileUrl.deletingPathExtension().deletingPathExtension().lastPathComponent.dropFirst() + " ")
                
                let icloudBadgeAttachment = NSTextAttachment(image: UIImage(systemName: "icloud.circle.fill")!)
                let icloudBadge = NSAttributedString(attachment: icloudBadgeAttachment)
                fileNameAttributedString.append(icloudBadge)
            }
            
            fileNameLabel.attributedText = fileNameAttributedString
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
                contentView.backgroundColor = UIColor.secondarySystemBackground
            } else {
                contentView.backgroundColor = nil
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
        contentView.addSubview(fileNameLabel)
        
        imageContainerView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            imageContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            imageContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            imageContainerView.heightAnchor.constraint(equalTo: imageContainerView.widthAnchor),
            
            fileNameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            fileNameLabel.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            fileNameLabel.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor)
        ])
        
        contentView.layer.cornerRadius = 20
        contentView.layer.cornerCurve = .continuous
        
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
        
        document = nil
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        imageContainerView.layer.shadowPath = UIBezierPath(roundedRect: imageContainerView.bounds, cornerRadius: 20).cgPath
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
