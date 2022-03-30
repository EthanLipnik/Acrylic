//
//  ProjectNavigatorViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/27/22.
//

import UIKit
import UniformTypeIdentifiers
import QuickLook

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
    
    enum Document: Hashable {
        case mesh(MeshDocument)
        case scene(SceneDocument)
        
        var uiDocument: UIDocument {
            switch self {
            case .mesh(let meshDocument):
                return meshDocument as UIDocument
            case .scene(let sceneDocument):
                return sceneDocument as UIDocument
            }
        }
        
        func open(completion: ((Bool) -> Void)? = nil) {
            uiDocument.open(completionHandler: completion)
        }
        
        func close(completion: ((Bool) -> Void)? = nil) {
            uiDocument.close(completionHandler: completion)
        }
        
        var documentState: UIDocument.State {
            return uiDocument.documentState
        }
        
        var fileUrl: URL? {
            switch self {
            case .mesh(let meshDocument):
                return meshDocument.fileURL
            case .scene(let sceneDocument):
                return sceneDocument.fileURL
            }
        }
    }
    
    lazy var dataSource: UICollectionViewDiffableDataSource<Section, Document> = {
        let dataSource = UICollectionViewDiffableDataSource<Section, Document>(collectionView: navigatorView.collectionView) { (collectionView, indexPath, document) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProjectCollectionViewCell.reuseIdentifer, for: indexPath) as! ProjectCollectionViewCell
            
            cell.document = document
            
#if targetEnvironment(macCatalyst)
            cell.doubleClickAction = { [weak self] in
                self?.openDocument(document)
            }
#endif
            cell.singleClickAction = { [weak self] in
#if !targetEnvironment(macCatalyst)
                self?.openDocument(document)
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
            UIAction(title: "Mesh Gradient", handler: { [weak self] action in
                self?.createDocument("Mesh", type: .acrylicMeshGradient)
            }),
            UIAction(title: "3D Scene", state: .off, handler: { [weak self] action in
                self?.createDocument("Scene", type: .acrylicScene)
            })
        ])
        navigationItem.rightBarButtonItem = newProjectButton
        
        navigationItem.title = "Acrylic"
        navigationController?.navigationBar.prefersLargeTitles = true
        
#if targetEnvironment(macCatalyst)
        navigationController?.setNavigationBarHidden(true, animated: false)
#endif
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Document>()
        snapshot.appendSections([.mesh, .scene])
        
        snapshot.appendItems(meshDocuments, toSection: .mesh)
        snapshot.appendItems(sceneDocuments, toSection: .scene)
        
        print(sceneDocuments)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applySnapshot()
    }
    
    func openDocument(_ document: Document) {
        switch document {
        case .mesh(let meshDocument):
            meshDocument.open { [weak self] success in
                if success {
                    let editorViewController = MeshEditorViewController(meshDocument)
                    editorViewController.modalPresentationStyle = .fullScreen
                    self?.present(editorViewController, animated: true) {
                        self?.updateToolbar()
                    }
                } else {
                    print("Failed to open")
                }
            }
        case .scene(let sceneDocument):
            sceneDocument.open { [weak self] success in
                if success {
                    let editorViewController = SceneEditorViewController(sceneDocument)
                    editorViewController.modalPresentationStyle = .fullScreen
                    self?.present(editorViewController, animated: true) {
                        self?.updateToolbar()
                    }
                } else {
                    print("Failed to open")
                }
            }
        }
    }
    
    func createDocument(_ name: String, type: UTType) {
        var nameIndex: Int = 0
        var url = AppDelegate.documentsFolder.appendingPathComponent(name).appendingPathExtension(for: type)
        
        while FileManager.default.fileExists(atPath: url.path) {
            nameIndex += 1
            url = AppDelegate.documentsFolder.appendingPathComponent("\(name) \(nameIndex)").appendingPathExtension(for: type)
        }
        
        switch type {
        case .acrylicMeshGradient:
            let document = MeshDocument(fileURL: url)
            document.save(to: url, for: .forCreating)
            
            document.open { [weak self] _ in
                let editorViewController = MeshEditorViewController(document)
                editorViewController.modalPresentationStyle = .fullScreen
                self?.present(editorViewController, animated: true) {
                    self?.applySnapshot()
                }
                
                self?.updateToolbar()
            }
        case .acrylicScene:
            let document = SceneDocument(fileURL: url)
            document.save(to: url, for: .forCreating)
            
            document.open { [weak self] _ in
                let editorViewController = SceneEditorViewController(document)
                editorViewController.modalPresentationStyle = .fullScreen
                self?.present(editorViewController, animated: true) {
                    self?.applySnapshot()
                }
                
                self?.updateToolbar()
            }
        default:
            break
        }
    }
    
    func updateToolbar() {
#if targetEnvironment(macCatalyst)
            let scene = UIApplication.shared.connectedScenes.first
            if let sceneDelegate = scene?.delegate as? SceneDelegate {
                sceneDelegate.updateToolbar()
            }
#endif
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, selectionFollowsFocusForItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let document = dataSource.itemIdentifier(for: indexPath) else { return nil }
        return .init(identifier: nil, previewProvider: nil) { menu in
            return UIMenu(title: document.fileUrl?.lastPathComponent ?? "Document", children: [
                UIAction(title: "Delete", image: UIImage(systemName: "trash"), discoverabilityTitle: "Delete document", attributes: .destructive, handler: { action in
                    
                })
            ])
        }
    }
}

extension ProjectNavigatorViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return AppDelegate.documentsFolder.appendingPathComponent("Scene.ausf") as NSURL
    }
}
