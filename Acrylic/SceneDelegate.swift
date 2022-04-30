//
//  SceneDelegate.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import UIKit
import SwiftUI
import CoreImage
import TelemetryClient

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var projectNavigator = ProjectNavigatorViewController()
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UINavigationController(rootViewController: projectNavigator)
        window?.makeKeyAndVisible()
        
#if targetEnvironment(macCatalyst)
        addToolbar()
#endif
        
        window?.windowScene?.sizeRestrictions?.minimumSize = CGSize(width: 720, height: 600)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let fileUrl = URLContexts.first?.url {
            self.window?.openDocument(fileUrl)
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        projectNavigator.applySnapshot()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    @objc final func export() {
        if var topController = window?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let renderImage: UIImage
            if let meshService = (topController as? MeshEditorViewController)?.meshService {
                renderImage = meshService.render(resolution: CGSize(width: 8000, height: 8000))
            } else if let sceneService = (topController as? SceneEditorViewController)?.sceneService {
                renderImage = sceneService.render(resolution: CGSize(width: 8000, height: 8000))
            } else {
                renderImage = UIImage()
            }
            
            let vc = UIHostingController(rootView: ExportView(renderImage: renderImage))
            
#if targetEnvironment(macCatalyst)
            vc.preferredContentSize = CGSize(width: 1024, height: 512)
#else
            vc.modalPresentationStyle = .formSheet
#endif
            
            topController.present(vc, animated: true)
        }
    }
}

#if targetEnvironment(macCatalyst)
extension SceneDelegate: NSToolbarDelegate {
    
    func addToolbar() {
        if let titleBar = window?.windowScene?.titlebar {
            let toolbar = NSToolbar(identifier: "Toolbar")
            toolbar.delegate = self
            toolbar.displayMode = .iconOnly
            toolbar.allowsUserCustomization = false
            
            titleBar.toolbar = toolbar
            titleBar.titleVisibility = .visible
        }
    }
    
    func removeToolbar() {
        window?.windowScene?.titlebar?.toolbar = nil
        window?.windowScene?.titlebar?.titleVisibility = .hidden
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.init("newProject")]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .init("newProject"):
            let item = NSMenuToolbarItem(itemIdentifier: itemIdentifier)
            item.image = UIImage(systemName: "plus")
            
            item.itemMenu = UIMenu(title: "New Project", children: [
                UIAction(title: "Mesh Gradient", handler: { action in
                    Task(priority: .userInitiated) { [weak self] in
                        do {
                            if let navigationController = self?.window?.rootViewController as? UINavigationController, let projectNavigator = navigationController.topViewController as? ProjectNavigatorViewController {
                                try await projectNavigator.createDocument("Mesh", type: .acrylicMeshGradient)
                            }
                        } catch {
                            print(error)
                        }
                    }
                }),
                UIAction(title: "3D Scene", state: .off, handler: { action in
                    Task(priority: .userInitiated) { [weak self] in
                        do {
                            if let navigationController = self?.window?.rootViewController as? UINavigationController, let projectNavigator = navigationController.topViewController as? ProjectNavigatorViewController {
                                try await projectNavigator.createDocument("Scene", type: .acrylicScene)
                            }
                        } catch {
                            print(error)
                        }
                    }
                })
            ])
            
            if var topController = window?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                
                if (topController is MeshEditorViewController || topController is SceneEditorViewController) {
                    item.target = nil
                    item.action = nil
                }
            }
            
            return item
        default:
            return NSToolbarItem(itemIdentifier: itemIdentifier)
        }
    }
}
#endif

extension UIWindow {
    func openDocument(_ url: URL, destroysCurrentScene: Bool = true, alwaysUseNewWindow: Bool = false) {
        guard url.pathExtension != "icloud" else {
            do {
                try FileManager.default.startDownloadingUbiquitousItem(at: url)
            } catch {
                print(error)
            }
            return
        }
        
        let openInNewWindow = alwaysUseNewWindow || UIDevice.current.userInterfaceIdiom == .mac
        
        if openInNewWindow {
            let activity = NSUserActivity(activityType: "editor")
            activity.userInfo = ["filePath": url.path]
            
            UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { (error) in
                print(error)
            }
            
            TelemetryManager.send("documentOpened")
            
            if let session = windowScene?.session, destroysCurrentScene {
                UIApplication.shared.requestSceneSessionDestruction(session, options: nil) { error in
                    print(error)
                }
            }
        } else {
            do {
                let document = try Document.fromURL(url)
                document.open { [weak self] success in
                    if success {
                        let editorViewController: UIViewController
                        
                        switch document {
                        case .mesh(let meshDocument):
                            editorViewController = MeshEditorViewController(meshDocument)
                        case .scene(let sceneDocument):
                            editorViewController = SceneEditorViewController(sceneDocument)
                        }
                        editorViewController.modalPresentationStyle = .fullScreen
                        
                        if var topController = self?.rootViewController {
                            while let presentedViewController = topController.presentedViewController {
                                topController = presentedViewController
                            }
                            
                            topController.dismiss(animated: true) {
                                self?.rootViewController?.present(editorViewController, animated: true)
                            }
                        }
                        
                        self?.windowScene?.title = document.fileUrl?.lastPathComponent
                        
                        TelemetryManager.send("documentOpened")
                    } else {
                        print("Failed to open")
                    }
                }
            } catch {
                print(error)
            }
        }
    }
}
