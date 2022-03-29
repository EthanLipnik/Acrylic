//
//  ProjectCollectionViewCell.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/27/22.
//

import UIKit
import RandomColor

class ProjectCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    static let reuseIdentifer = String(describing: ProjectCollectionViewCell.self)
    
    var document: ProjectNavigatorViewController.Document? = nil {
        didSet {
            guard let document = document, let fileUrl = document.fileUrl else {
                
                self.imageView.image = nil
                return
            }
            self.imageView.image = UIImage(contentsOfFile: fileUrl.appendingPathComponent("PreviewImage.heic").path)
        }
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFill
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        imageView.backgroundColor = randomColor(hue: .random, luminosity: .bright)
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.cornerCurve = .continuous
        
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
        imageView.frame = contentView.bounds
        
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 15).cgPath
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
