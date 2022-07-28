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
            collectionView.dragDelegate = viewController
        }
    }

    lazy var layout: UICollectionViewCompositionalLayout = UICollectionViewCompositionalLayout {
        (_: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

        let squareItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                   heightDimension: .fractionalHeight(1.0)))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(300),
                                                                                        heightDimension: .absolute(340)),
                                                     subitems: [squareItem])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
        section.interGroupSpacing = 5

        let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(28))
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize, elementKind: ProjectHeaderCollectionReusableView.reuseIdentifer, alignment: .top)
        headerItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        section.boundarySupplementaryItems = [headerItem]

        return section
    }

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = viewController
        collectionView.dragDelegate = viewController
        collectionView.allowsSelection = UIDevice.current.userInterfaceIdiom != .phone
        collectionView.allowsMultipleSelection = UIDevice.current.userInterfaceIdiom != .phone
        collectionView.allowsSelectionDuringEditing = true

        collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)

        collectionView.register(ProjectCollectionViewCell.self, forCellWithReuseIdentifier: ProjectCollectionViewCell.reuseIdentifer)
        collectionView.register(ProjectHeaderCollectionReusableView.self, forSupplementaryViewOfKind: ProjectHeaderCollectionReusableView.reuseIdentifer, withReuseIdentifier: ProjectHeaderCollectionReusableView.reuseIdentifer)

        if #available(iOS 15.0, macOS 12.0, *) {
            collectionView.allowsFocus = UIDevice.current.userInterfaceIdiom != .phone
            collectionView.selectionFollowsFocus = UIDevice.current.userInterfaceIdiom != .phone
        }

        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return collectionView
    }()

    lazy var createProjectLabel: UILabel = {
        let label = UILabel()

        label.text = "Your project navigator is empty. Tap the plus in the top right corner to create a new project."
        label.font = UIFont.preferredFont(forTextStyle: .title1, compatibleWith: traitCollection)
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0

        label.isHidden = true
        label.isUserInteractionEnabled = false

        label.translatesAutoresizingMaskIntoConstraints = false

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
        addSubview(collectionView)
        addSubview(createProjectLabel)

        NSLayoutConstraint.activate([
            createProjectLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            createProjectLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            createProjectLabel.widthAnchor.constraint(equalTo: readableContentGuide.widthAnchor)
        ])
    }
}
