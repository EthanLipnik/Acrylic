//
//  ProjectNavigatorViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/27/22.
//

import UIKit
import UniformTypeIdentifiers
import SwiftUI
import DirectoryWatcher
import TelemetryClient
import UIOnboarding
import SceneKit
import MeshKit

class ProjectNavigatorViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDragDelegate {
    
    lazy var navigatorView: ProjectNavigatorView = {
        let view = ProjectNavigatorView()
        
        view.viewController = self
        
        return view
    }()
    
    lazy var onboardingVC: UIOnboardingViewController = {
        let features: [UIOnboardingFeature] = [
            UIOnboardingFeature(icon: UIImage(systemName: "square.fill", compatibleWith: traitCollection)!,
                                title: "Mesh Gradients",
                                description: "Create beautiful mesh gradients."),
            UIOnboardingFeature(icon: UIImage(systemName: "cube.fill", compatibleWith: traitCollection)!,
                                title: "Scenes",
                                description: "Easily design great looking 3D scenes with presets."),
            UIOnboardingFeature(icon: UIImage(systemName: "square.stack.fill", compatibleWith: traitCollection)!,
                                title: "Automation",
                                description: "Use Siri Shortcuts to automate your mesh gradients."),
            UIOnboardingFeature(icon: UIImage(systemName: "number", compatibleWith: traitCollection)!,
                                title: "Share",
                                description: "Show your great work using the #AcrylicApp hashtag.")
        ]
        
        let attributedString = NSMutableAttributedString(string: "Welcome to Acrylic")
        attributedString.addAttribute(.foregroundColor, value: UIColor(patternImage: UIImage(named: "MeshLong")!), range: NSRange(location: 11, length: 7))
        
        let config = UIOnboardingViewConfiguration(appIcon: UIImage(named: "Icon")!,
                                                   welcomeTitle: attributedString,
                                                   features: features,
                                                   textViewConfiguration: .init(icon: UIImage(systemName: "paintbrush.pointed.fill",
                                                                                              compatibleWith: traitCollection)!,
                                                                                text: "Developed and designed by Ethan Lipnik.",
                                                                                linkTitle: "Learn more...",
                                                                                link: "https://acrylicapp.io"),
                                                   buttonConfiguration: .init(title: "Get Started",
                                                                              backgroundColor: UIColor.systemTeal))
        
        let vc = UIOnboardingViewController(withConfiguration: config)
        vc.delegate = self
        
        return vc
    }()
    
    var documents: (mesh: [Document], scene: [Document]) {
        do {
            func isMesh(_ fileUrl: URL) -> Bool {
                return fileUrl.pathExtension == "amgf" || fileUrl.lastPathComponent.hasSuffix("amgf.icloud")
            }
            func isScene(_ fileUrl: URL) -> Bool {
                return fileUrl.pathExtension == "ausf" || fileUrl.lastPathComponent.hasSuffix("ausf.icloud")
            }
            
            let documents = (try FileManager.default.contentsOfDirectory(atURL: AppDelegate.documentsFolder, sortedBy: .modified, ascending: false, options: [.skipsSubdirectoryDescendants]) ?? [])
                .map({ AppDelegate.documentsFolder.appendingPathComponent($0) })
            
            return (
                mesh: documents.filter({ isMesh($0) }).map({ Document.mesh(MeshDocument(fileURL: $0)) }),
                scene: documents.filter({ isScene($0) }).map({ Document.scene(SceneDocument(fileURL: $0)) })
            )
        } catch {
            print(error)
            return ([], [])
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
    
    lazy var directoryWatcher: DirectoryWatcher? = {
        let watcher = DirectoryWatcher.watch(AppDelegate.documentsFolder)
        
        watcher?.onNewFiles = { [weak self] _ in
            self?.applySnapshot()
        }
        
        watcher?.onDeletedFiles = watcher?.onNewFiles
        
        return watcher
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applySnapshot()
        
        let showOnboardingButton = UIBarButtonItem(image: UIImage(systemName: "info.circle", compatibleWith: traitCollection), style: .done, target: self, action: #selector(showOnboarding))
        
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
        navigationItem.leftBarButtonItem = showOnboardingButton
        
        navigationItem.title = "Acrylic"
        navigationController?.navigationBar.prefersLargeTitles = true
        
#if targetEnvironment(macCatalyst)
        navigationController?.setNavigationBarHidden(true, animated: false)
#endif
        
        let _ = directoryWatcher?.startWatching()
    }
    
    @objc func showOnboarding() {
        self.present(onboardingVC, animated: true)
    }
    
    func applySnapshot(completion: @escaping () -> Void = {}) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Document>()
        
        let documents = self.documents
        if !documents.mesh.isEmpty {
            snapshot.appendSections([.mesh])
            snapshot.appendItems(documents.mesh, toSection: .mesh)
        }
        
        if !documents.scene.isEmpty {
            snapshot.appendSections([.scene])
            snapshot.appendItems(documents.scene, toSection: .scene)
        }
        
        navigatorView.createProjectLabel.isHidden = !(documents.mesh.isEmpty && documents.scene.isEmpty)
        
        dataSource.apply(snapshot, animatingDifferences: true, completion: completion)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applySnapshot()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.window?.windowScene?.title = nil
        
        let _ = directoryWatcher?.startWatching()
        
        if !UserDefaults.standard.bool(forKey: "didFinishOnboarding") {
#if targetEnvironment(macCatalyst)
            (view.window?.windowScene?.delegate as? SceneDelegate)?.removeToolbar()
#endif
            self.present(onboardingVC, animated: false)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let _ = directoryWatcher?.stopWatching()
    }
    
    func createDocument(_ name: String, type: UTType) async throws {
        var nameIndex: Int = 0
        var url = AppDelegate.documentsFolder.appendingPathComponent(name).appendingPathExtension(for: type)
        
        while FileManager.default.fileExists(atPath: url.path) {
            nameIndex += 1
            url = AppDelegate.documentsFolder.appendingPathComponent("\(name) \(nameIndex)").appendingPathExtension(for: type)
        }
        
        var document: UIDocument?
        var typeName: String = ""
        
        switch type {
        case .acrylicMeshGradient:
            document = MeshDocument(fileURL: url)
            typeName = "mesh"
        case .acrylicScene:
            document = SceneDocument(fileURL: url)
            typeName = "scene"
        default:
            break
        }
        
        guard let didSave = await document?.save(to: url, for: .forCreating), didSave else {
            throw CocoaError(.fileWriteUnknown)
        }
        
        applySnapshot { [weak self] in
            self?.view.window?.openDocument(url)
        }
        
        TelemetryManager.send("documentCreated", with: ["type": typeName])
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
        guard let document = dataSource.itemIdentifier(for: indexPath), let fileUrl = document.fileUrl else { return nil }
        
        let selectedIndexPaths = collectionView.indexPathsForSelectedItems ?? []
        var fileUrls = selectedIndexPaths.compactMap({ dataSource.itemIdentifier(for: $0)?.fileUrl })
        
        if !fileUrls.contains(fileUrl) {
            fileUrls.append(fileUrl)
        }
        
        print("Selection", fileUrls)
        
        return .init(identifier: nil, previewProvider: nil) { [weak self] menu in
            var children: [UIMenuElement] = [
                UIMenu(title: "", options: .displayInline, children: [
                    UIAction(title: "Delete", image: UIImage(systemName: "trash"), discoverabilityTitle: "Delete document", attributes: .destructive, handler: { action in
                        let alertController = UIAlertController(title: "Delete \(fileUrls.count > 1 ? "\(fileUrls.count) documents" : fileUrl.lastPathComponent)?", message: "You won't be able to undo this.", preferredStyle: .actionSheet)
                        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                            for url in fileUrls {
                                var finalUrl: NSURL?
                                do {
                                    try FileManager.default.trashItem(at: url, resultingItemURL: &finalUrl)
                                } catch {
                                    print(error)
                                    do {
                                        try FileManager.default.removeItem(at: url)
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                        }))
                        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        
                        let cell = collectionView.cellForItem(at: indexPath)
                        alertController.popoverPresentationController?.sourceRect = cell?.bounds ?? CGRect(origin: point, size: .zero)
                        alertController.popoverPresentationController?.sourceView = cell ?? collectionView
                        
                        self?.present(alertController, animated: true)
                    })
                ])
            ]
            
            if document.fileUrl?.pathExtension != "icloud" {
                if fileUrls.count == 1 {
                    children.append(UIMenu(title: "", options: .displayInline, children: [
                        UIAction(title: "Export", image: UIImage(systemName: "square.and.arrow.up"), discoverabilityTitle: "Export document", handler: { _ in
                            document.open { _ in
                                let vc = UIHostingController(rootView: ExportView(document: document))
                                
    #if targetEnvironment(macCatalyst)
                                vc.preferredContentSize = CGSize(width: 1024, height: 512)
    #else
                                vc.modalPresentationStyle = .formSheet
    #endif
                                self?.present(vc, animated: true)
                            }
                        })
                    ]))
                }
                
                if UIDevice.current.userInterfaceIdiom != .phone {
                    children.insert(UIAction(title: "Open in New Window" + (fileUrls.count > 1 ? " (\(fileUrls.count))" : ""), discoverabilityTitle: "Open document(s) in new window", handler: { action in
                        fileUrls.forEach({ self?.view.window?.openDocument($0, destroysCurrentScene: false, alwaysUseNewWindow: true) })
                    }), at: 0)
                }
                
                if fileUrls.count == 1 {
                    children.insert(UIAction(title: "Open", discoverabilityTitle: "Open document", handler: { action in
                        self?.view.window?.openDocument(fileUrl)
                    }), at: 0)
                    
                    if AppDelegate.isCloudFolder {
                        children.insert(UIAction(title: "Remove download", discoverabilityTitle: "Remove download of document", handler: { action in
                            do {
                                try FileManager.default.evictUbiquitousItem(at: fileUrl)
                            } catch {
                                print(error)
                            }
                        }), at: 2)
                    }
                }
            } else {
                if fileUrls.count == 1 {
                    children.insert(UIAction(title: "Download", discoverabilityTitle: "Download document", handler: { action in
                        do {
                            try FileManager.default.startDownloadingUbiquitousItem(at: fileUrl)
                        } catch {
                            print(error)
                        }
                    }), at: 0)
                }
            }
            
            return UIMenu(title: document.fileUrl?.lastPathComponent ?? "Document", children: children)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let item = dataSource.itemIdentifier(for: indexPath), let fileUrl = item.fileUrl, let provider = NSItemProvider(contentsOf: fileUrl) else { return [] }
        return [UIDragItem(itemProvider: provider)]
    }
}

extension FileManager {

    enum ContentDate {
        case created, modified, accessed

        var resourceKey: URLResourceKey {
            switch self {
            case .created: return .creationDateKey
            case .modified: return .contentModificationDateKey
            case .accessed: return .contentAccessDateKey
            }
        }
    }

    func contentsOfDirectory(atURL url: URL, sortedBy: ContentDate, ascending: Bool = true, options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]) throws -> [String]? {

        let key = sortedBy.resourceKey

        var files = try contentsOfDirectory(at: url, includingPropertiesForKeys: [key], options: options)

        try files.sort {

            let values1 = try $0.resourceValues(forKeys: [key])
            let values2 = try $1.resourceValues(forKeys: [key])

            if let date1 = values1.allValues.first?.value as? Date, let date2 = values2.allValues.first?.value as? Date {

                return date1.compare(date2) == (ascending ? .orderedAscending : .orderedDescending)
            }
            return true
        }
        return files.map { $0.lastPathComponent }
    }
}
