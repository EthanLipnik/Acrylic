//
//  ProjectNavigatorViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/27/22.
//

import UIKit
import UniformTypeIdentifiers

class ProjectNavigatorViewController: UIViewController, UICollectionViewDelegate {
    
    lazy var navigatorView: ProjectNavigatorView = {
        let view = ProjectNavigatorView()
        
        view.viewController = self
        
        return view
    }()
    
    lazy var meshDocuments: [Document] = {
        do {
            let documents = try FileManager.default.contentsOfDirectory(atPath: AppDelegate.documentsFolder.path)
                .map({ AppDelegate.documentsFolder.appendingPathComponent($0) })
                .filter({ UTType(filenameExtension: $0.pathExtension) == .acrylicMeshGradient })
                .map({ MeshDocument(fileURL: $0) })
            
            return documents.map({ Document.mesh($0) })
        } catch {
            print(error)
            return []
        }
    }()
    
    enum Section: CaseIterable {
        case mesh
        case scene
    }
    
    enum Document: Hashable {
        case mesh(MeshDocument)
        case scene(title: String)
        
        func open(completion: ((Bool) -> Void)? = nil) {
            switch self {
            case .mesh(let meshDocument):
                meshDocument.open(completionHandler: completion)
            default:
                break
            }
        }
        
        func close(completion: ((Bool) -> Void)? = nil) {
            switch self {
            case .mesh(let meshDocument):
                meshDocument.close(completionHandler: completion)
            default:
                break
            }
        }
        
        var documentState: UIDocument.State {
            switch self {
            case .mesh(let meshDocument):
                return meshDocument.documentState
            default:
                return .closed
            }
        }
        
        var fileUrl: URL? {
            switch self {
            case .mesh(let meshDocument):
                return meshDocument.fileURL
            case .scene:
                return nil
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
            cell.singleClickAction = {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
            }
#endif
            
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
        
        applySnapshot(loadDocuments: false)
        
        let newProjectButton = UIBarButtonItem(systemItem: .add)
        newProjectButton.menu = UIMenu(title: "New Project", image: UIImage(systemName: "add"), children: [
            UIAction(title: "Mesh Gradient", handler: { [weak self] action in
                self?.createDocument()
            }),
            UIAction(title: "3D Scene", state: .off, handler: { action in
            })
        ])
        navigationItem.rightBarButtonItem = newProjectButton
        
        navigationItem.title = "Acrylic"
        navigationController?.navigationBar.prefersLargeTitles = true
        
#if targetEnvironment(macCatalyst)
        navigationController?.setNavigationBarHidden(true, animated: false)
#endif
    }
    
    func applySnapshot(loadDocuments: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Document>()
        snapshot.appendSections([.mesh, .scene])
        
        if loadDocuments {
            meshDocuments.forEach { document in
                if document.documentState == .normal {
                    document.close()
                }
                document.open { [weak self] success in
                    if success {
                        snapshot.appendItems([document], toSection: .mesh)
                        self?.dataSource.apply(snapshot, animatingDifferences: true)
                    }
                }
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applySnapshot()
    }
    
    func openDocument(_ document: Document) {
        switch document {
        case .mesh(let meshDocument):
            let editorViewController = MeshEditorViewController(meshDocument)
            editorViewController.modalPresentationStyle = .fullScreen
            present(editorViewController, animated: true)
        default:
            break
        }
        
#if targetEnvironment(macCatalyst)
        let scene = UIApplication.shared.connectedScenes.first
        if let sceneDelegate = scene?.delegate as? SceneDelegate {
            sceneDelegate.updateToolbar()
        }
#endif
    }
    
    func createDocument() {
        var nameIndex: Int = 0
        var url = AppDelegate.documentsFolder.appendingPathComponent("Mesh.amg")
        
        while FileManager.default.fileExists(atPath: url.path) {
            nameIndex += 1
            url = AppDelegate.documentsFolder.appendingPathComponent("Mesh \(nameIndex).amg")
        }
        
        let document = MeshDocument(fileURL: url)
        document.save(to: url, for: .forCreating)
        
        document.open { [weak self] _ in
            let editorViewController = MeshEditorViewController(document)
            editorViewController.modalPresentationStyle = .fullScreen
            self?.present(editorViewController, animated: true) {
                self?.meshDocuments.append(Document.mesh(document))
                self?.applySnapshot()
            }
            
#if targetEnvironment(macCatalyst)
            let scene = UIApplication.shared.connectedScenes.first
            if let sceneDelegate = scene?.delegate as? SceneDelegate {
                sceneDelegate.updateToolbar()
            }
#endif
        }
        
#if targetEnvironment(macCatalyst)
        let scene = UIApplication.shared.connectedScenes.first
        if let sceneDelegate = scene?.delegate as? SceneDelegate {
            sceneDelegate.updateToolbar()
        }
#endif
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
#if !targetEnvironment(macCatalyst)
        guard let document = dataSource.itemIdentifier(for: indexPath) else { return }
        openDocument(document)
#endif
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
        return .init(identifier: nil, previewProvider: nil) { menu in
            return UIMenu(title: document.fileUrl?.lastPathComponent ?? "Document", children: [
                UIAction(title: "Delete", image: UIImage(systemName: "trash"), discoverabilityTitle: "Delete document", attributes: .destructive, handler: { action in
                    
                })
            ])
        }
    }
}
