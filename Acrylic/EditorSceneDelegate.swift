//
//  EditorSceneDelegate.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 4/3/22.
//

import UIKit
import SwiftUI

#if targetEnvironment(macCatalyst)
typealias EditorDelegate = EditorSceneDelegate
#else
typealias EditorDelegate = SceneDelegate
#endif

enum Document: Hashable {
    case mesh(MeshDocument)
    case scene(SceneDocument)
    
    static func fromURL(_ url: URL) throws -> Document {
        switch url.pathExtension {
        case "amgf":
            return .mesh(MeshDocument(fileURL: url))
        case "ausf":
            return .scene(SceneDocument(fileURL: url))
        default:
            throw CocoaError(.fileReadUnknown)
        }
    }
    
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

class EditorSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    var document: Document?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        if let userActivity = (connectionOptions.userActivities.first(where: { $0.userInfo != nil }) ?? session.stateRestorationActivity), let userInfo = userActivity.userInfo,
           let filePath = userInfo["filePath"] as? String {
            scene.userActivity = userActivity
            
            let documentUrl = URL(fileURLWithPath: filePath)
            do {
                self.document = try Document.fromURL(documentUrl)
                
                windowScene.title = documentUrl.lastPathComponent
                
                document?.open { [weak self] success in
                    if success {
                        switch self?.document {
                        case .mesh(let meshDocument):
                            self?.window?.rootViewController = MeshEditorViewController(meshDocument)
                        case .scene(let sceneDocument):
                            self?.window?.rootViewController = SceneEditorViewController(sceneDocument)
                        default:
                            UIApplication.shared.requestSceneSessionDestruction(session, options: nil) { error in
                                print(error)
                            }
                            return
                        }
                    } else {
                        print("Failed to open document")
                        UIApplication.shared.requestSceneSessionDestruction(session, options: nil) { error in
                            print(error)
                        }
                    }
                }
            } catch {
                print(error)
            }
        } else {
            UIApplication.shared.requestSceneSessionDestruction(session, options: nil) { error in
                print(error)
            }
        }
        
        window?.makeKeyAndVisible()
        
#if targetEnvironment(macCatalyst)
        if let titleBar = windowScene.titlebar {
            let toolbar = NSToolbar(identifier: "Toolbar")
            toolbar.delegate = self
            toolbar.displayMode = .iconOnly
            toolbar.allowsUserCustomization = false
            
            titleBar.toolbar = toolbar
        }
        
        windowScene.sizeRestrictions?.minimumSize = CGSize(width: 720, height: 600)
#endif
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        
        document?.close { [weak self] _ in
            self?.document = nil
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let fileUrl = URLContexts.first?.url {
            self.window?.openDocument(fileUrl, destroysCurrentScene: false)
        }
    }
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        return scene.userActivity
    }
    
    @objc final func export() {
        if var topController = window?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            if let meshService = (topController as? MeshEditorViewController)?.meshService {
                meshService.isExporting.toggle()
                
                let renderImage = meshService.render()
                let vc = UIHostingController(rootView: ExportView(renderImage: renderImage, meshService: meshService))
                
#if targetEnvironment(macCatalyst)
                vc.preferredContentSize = CGSize(width: 1024, height: 512)
#else
                vc.modalPresentationStyle = .formSheet
#endif
                
                topController.present(vc, animated: true)
            }
        }
    }
}

#if targetEnvironment(macCatalyst)
extension EditorSceneDelegate: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.init("export")]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .init("export"):
            let button = UIBarButtonItem()
            button.image = UIImage(systemName: "tray.and.arrow.up.fill")
            button.action = #selector(export)
            button.target = self
            
            let item = NSToolbarItem(itemIdentifier: itemIdentifier, barButtonItem: button)
            item.label = "Export"
            
            return item
        default:
            return NSToolbarItem(itemIdentifier: itemIdentifier)
        }
    }
}
#endif
