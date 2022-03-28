//
//  ProjectHeaderCollectionReusableView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/27/22.
//

import UIKit

class ProjectHeaderCollectionReusableView: UICollectionReusableView {
    static let reuseIdentifer = String(describing: ProjectHeaderCollectionReusableView.self)
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.preferredFont(forTextStyle: .title1, compatibleWith: traitCollection)
        label.textAlignment = .left
        
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return label
    }()
    
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
        addSubview(titleLabel)
        titleLabel.frame = bounds
    }
}
