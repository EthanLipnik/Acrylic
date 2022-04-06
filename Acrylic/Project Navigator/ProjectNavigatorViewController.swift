//
//  ProjectNavigatorViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/27/22.
//

import UIKit
import UniformTypeIdentifiers
import SwiftUI

class ProjectNavigatorViewController: UIViewController, UICollectionViewDelegate {
    
    lazy var navigatorView: ProjectNavigatorView = {
        let view = ProjectNavigatorView()
        
        view.viewController = self
        
        return view
    }()
    
    var meshDocuments: [Document] {
        do {
            let documents = try FileManager.default.contentsOfDirectory(atPath: AppDelegate.documentsFolder.path)
                .map({ AppDelegate.documentsFolder.appendingPathComponent($0) })
                .filter({ $0.pathExtension == "amgf" || $0.lastPathComponent.hasSuffix("amgf.icloud") })
                .map({ MeshDocument(fileURL: $0) })
            
            return documents.map({ Document.mesh($0) })
        } catch {
            print(error)
            return []
        }
    }
    
    var sceneDocuments: [Document] {
        do {
            let documents = try FileManager.default.contentsOfDirectory(atPath: AppDelegate.documentsFolder.path)
                .map({ AppDelegate.documentsFolder.appendingPathComponent($0) })
                .filter({ $0.pathExtension == "ausf" || $0.lastPathComponent.hasSuffix("ausf.icloud") })
                .map({ SceneDocument(fileURL: $0) })
            
            return documents.map({ Document.scene($0) })
        } catch {
            print(error)
            return []
        }
    }
    
    enum Section: CaseIterable {
        case mesh
        case scene
    }
    
    lazy var dataSource: UICollectionViewDiffableDataSource<Section, Document> = {
        let dataSource = UICollectionViewDiffableDataSource<Section, Document>(collectionView: navigatorView.collectionView) { (collectionView, indexPath, document) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProjectCollectionViewCell.reuseIdentifer, for: indexPath) as! ProjectCollectionViewCell
            
            cell.document = document
            
#if targetEnvironment(macCatalyst)
            cell.doubleClickAction = { [weak self] in
                if let fileUrl = document.fileUrl {
                    self?.view.window?.openDocument(fileUrl)
                }
            }
#endif
            cell.singleClickAction = { [weak self] in
#if !targetEnvironment(macCatalyst)
                if let fileUrl = document.fileUrl {
                    self?.view.window?.openDocument(fileUrl)
                }
#else
                collectionView.indexPathsForSelectedItems?.forEach({ collectionView.deselectItem(at: $0, animated: false) })
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
#endif
            }
            
            return cell
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath -> UICollectionReusableView in
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: ProjectHeaderCollectionReusableView.reuseIdentifer,
                                                                             withReuseIdentifier: ProjectHeaderCollectionReusableView.reuseIdentifer,
                                                                             for: indexPath) as? ProjectHeaderCollectionReusableView else { return UICollectionReusableView() }
            
            switch indexPath.section {
            case 0:
                view.titleLabel.text = "Gradients"
            case 1:
                view.titleLabel.text = "Scenes"
            default:
                break
            }
            
            return view
        }
        
        return dataSource
    }()
    
    override func loadView() {
        super.loadView()
        
        self.view = navigatorView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applySnapshot()
        
        let newProjectButton = UIBarButtonItem(systemItem: .add)
        newProjectButton.menu = UIMenu(title: "New Project", image: UIImage(systemName: "add"), children: [
            UIAction(title: "Mesh Gradient", handler: { action in
                Task(priority: .userInitiated) { [weak self] in
                    do {
                        try await self?.createDocument("Mesh", type: .acrylicMeshGradient)
                    } catch {
                        print(error)
                    }
                }
            }),
            UIAction(title: "3D Scene", state: .off, handler: { action in
                Task(priority: .userInitiated) { [weak self] in
                    do {
                        try await self?.createDocument("Scene", type: .acrylicScene)
                    } catch {
                        print(error)
                    }
                }
            })
        ])
        navigationItem.rightBarButtonItem = newProjectButton
        
        navigationItem.title = "Acrylic"
        navigationController?.navigationBar.prefersLargeTitles = true
        
#if targetEnvironment(macCatalyst)
        navigationController?.setNavigationBarHidden(true, animated: false)
#endif
    }
    
    func applySnapshot(completion: @escaping () -> Void = {}) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Document>()
        
        if !meshDocuments.isEmpty {
            snapshot.appendSections([.mesh])
            snapshot.appendItems(meshDocuments, toSection: .mesh)
        }
        
        if !sceneDocuments.isEmpty {
            snapshot.appendSections([.scene])
            snapshot.appendItems(sceneDocuments, toSection: .scene)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true, completion: completion)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applySnapshot()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.window?.windowScene?.title = nil
    }
    
    func createDocument(_ name: String, type: UTType) async throws {
        var nameIndex: Int = 0
        var url = AppDelegate.documentsFolder.appendingPathComponent(name).appendingPathExtension(for: type)
        
        while FileManager.default.fileExists(atPath: url.path) {
            nameIndex += 1
            url = AppDelegate.documentsFolder.appendingPathComponent("\(name) \(nameIndex)").appendingPathExtension(for: type)
        }
        
        var document: UIDocument?
        
        switch type {
        case .acrylicMeshGradient:
            document = MeshDocument(fileURL: url)
        case .acrylicScene:
            document = SceneDocument(fileURL: url)
        default:
            break
        }
        
        guard let didSave = await document?.save(to: url, for: .forCreating), didSave else {
            throw CocoaError(.fileWriteUnknown)
        }
        
        applySnapshot { [weak self] in
#if !targetEnvironment(macCatalyst)
            self?.view.window?.openDocument(url)
#endif
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return UIDevice.current.userInterfaceIdiom != .phone
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        return UIDevice.current.userInterfaceIdiom != .phone
    }
    
    func collectionView(_ collectionView: UICollectionView, selectionFollowsFocusForItemAt indexPath: IndexPath) -> Bool {
        return UIDevice.current.userInterfaceIdiom != .phone
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        return UIDevice.current.userInterfaceIdiom != .phone
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let document = dataSource.itemIdentifier(for: indexPath) else { return nil }
        return .init(identifier: nil, previewProvider: nil) { [weak self] menu in
            var children: [UIMenuElement] = [
                UIMenu(title: "", options: .displayInline, children: [
                    UIAction(title: "Export", image: UIImage(systemName: "square.and.arrow.up"), discoverabilityTitle: "Export document", handler: { _ in
                        switch document {
                        case .mesh(let meshDocument):
                            let meshService = MeshService(meshDocument)
                            let renderImage = meshService.render()
                            
                            let vc = UIHostingController(rootView: ExportView(renderImage: renderImage, meshService: meshService))
                            
            #if targetEnvironment(macCatalyst)
                            vc.preferredContentSize = CGSize(width: 1024, height: 512)
            #else
                            vc.modalPresentationStyle = .formSheet
            #endif
                            self?.present(vc, animated: true)
                        default:
                            break
                        }
                    })
                ]),
                
                UIMenu(title: "", options: .displayInline, children: [
                    UIAction(title: "Delete", image: UIImage(systemName: "trash"), discoverabilityTitle: "Delete document", attributes: .destructive, handler: { action in
                        let alertController = UIAlertController(title: "Delete \(document.fileUrl?.lastPathComponent ?? "document")?", message: "You won't be able to undo this.", preferredStyle: .actionSheet)
                        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                            if let url = document.fileUrl {
                                var finalUrl: NSURL?
                                do {
                                    try FileManager.default.trashItem(at: url, resultingItemURL: &finalUrl)
                                    self?.applySnapshot()
                                } catch {
                                    print(error)
                                }
                            }
                        }))
                        
                        let cell = collectionView.cellForItem(at: indexPath)
                        alertController.popoverPresentationController?.sourceRect = cell?.bounds ?? CGRect(origin: point, size: .zero)
                        alertController.popoverPresentationController?.sourceView = cell ?? collectionView
                        
                        self?.present(alertController, animated: true)
                    })
                ])
            ]
            
#if targetEnvironment(macCatalyst)
            if let fileUrl = document.fileUrl {
                children.insert(UIAction(title: "Open in New Window", discoverabilityTitle: "Open document in new window", handler: { action in
                    self?.view.window?.openDocument(fileUrl, destroysCurrentScene: false)
                }), at: 0)
                children.insert(UIAction(title: "Open", discoverabilityTitle: "Open document", handler: { action in
                    self?.view.window?.openDocument(fileUrl)
                }), at: 0)
            }
#endif
            
            return UIMenu(title: document.fileUrl?.lastPathComponent ?? "Document", children: children)
        }
    }
}
