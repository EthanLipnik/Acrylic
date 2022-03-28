//
//  ProjectNavigatorView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/27/22.
//

import UIKit

class ProjectNavigatorView: UIView {
    
    weak var viewController: ProjectNavigatorViewController? {
        didSet {
            collectionView.delegate = viewController
        }
    }
    
    lazy var layout: UICollectionViewCompositionalLayout = {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            let squareItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalHeight(1.0),
                                                                                        heightDimension: .fractionalHeight(1.0)))
            squareItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(300),
                                                                                               heightDimension: .absolute(300)),
                                                            subitems: [squareItem])
            group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            
            let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize, elementKind: ProjectHeaderCollectionReusableView.reuseIdentifer, alignment: .top)
            headerItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
            section.boundarySupplementaryItems = [headerItem]

            return section
        }
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = viewController
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(ProjectCollectionViewCell.self, forCellWithReuseIdentifier: ProjectCollectionViewCell.reuseIdentifer)
        collectionView.register(ProjectHeaderCollectionReusableView.self, forSupplementaryViewOfKind: ProjectHeaderCollectionReusableView.reuseIdentifer, withReuseIdentifier: ProjectHeaderCollectionReusableView.reuseIdentifer)
        
        if #available(iOS 15.0, macCatalyst 15.0, *) {
            collectionView.allowsFocus = UIDevice.current.userInterfaceIdiom != .phone
            collectionView.selectionFollowsFocus = UIDevice.current.userInterfaceIdiom != .phone
        }
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return collectionView
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
        addSubview(collectionView)
    }
}
