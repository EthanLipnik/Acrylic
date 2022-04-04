//
//  SceneDelegate.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import UIKit
import SwiftUI
import CoreImage

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UINavigationController(rootViewController: ProjectNavigatorViewController())
        window?.makeKeyAndVisible()
        
#if targetEnvironment(macCatalyst)
        if let titleBar = windowScene.titlebar {
            let toolbar = NSToolbar(identifier: "Toolbar")
            toolbar.delegate = self
            toolbar.displayMode = .iconOnly
            toolbar.allowsUserCustomization = false
            
            titleBar.toolbar = toolbar
            
            titleBar.separatorStyle = .none
        }
        
        windowScene.sizeRestrictions?.minimumSize = CGSize(width: 720, height: 600)
#endif
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
extension SceneDelegate: NSToolbarDelegate {
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
                UIAction(title: "Mesh Gradient", handler: { [weak self] action in
                    if let navigationController = self?.window?.rootViewController as? UINavigationController, let projectNavigator = navigationController.topViewController as? ProjectNavigatorViewController {
                        projectNavigator.createDocument("Mesh", type: .acrylicMeshGradient)
                    }
                }),
                UIAction(title: "3D Scene", state: .off, handler: { [weak self] action in
                    if let navigationController = self?.window?.rootViewController as? UINavigationController, let projectNavigator = navigationController.topViewController as? ProjectNavigatorViewController {
                        projectNavigator.createDocument("Scene", type: .acrylicScene)
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
    func openDocument(_ url: URL, destroysCurrentScene: Bool = true) {
#if targetEnvironment(macCatalyst)
        let activity = NSUserActivity(activityType: "editor")
        activity.userInfo = ["fileUrl": url]
        
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { (error) in
            print(error)
        }
        
        if let session = windowScene?.session, destroysCurrentScene {
            UIApplication.shared.requestSceneSessionDestruction(session, options: nil) { error in
                print(error)
            }
        }
        
#else
        
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
                } else {
                    print("Failed to open")
                }
            }
        } catch {
            print(error)
        }
#endif
    }
}
