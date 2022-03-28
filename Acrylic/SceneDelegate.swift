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
            toolbar.allowsUserCustomization = true
            
            titleBar.toolbar = toolbar
            
            titleBar.separatorStyle = .none
        }
        
        windowScene.sizeRestrictions?.minimumSize = CGSize(width: 720, height: 600)
#endif
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
            
            if let meshService = (topController as? SplitViewController)?.meshService {
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
    
    @objc final func goBack() {
        if var topController = window?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.dismiss(animated: true) { [weak self] in
#if targetEnvironment(macCatalyst)
                self?.updateToolbar()
#endif
            }
        }
    }
}

#if targetEnvironment(macCatalyst)
extension SceneDelegate: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.toggleSidebar, .init("back"), .flexibleSpace, .init("newProject"), .init("export")]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .init("back"):
            let button = UIBarButtonItem()
            button.image = UIImage(systemName: "chevron.left")
            button.action = #selector(goBack)
            button.target = self
            
            let item = NSToolbarItem(itemIdentifier: itemIdentifier, barButtonItem: button)
            item.label = "Back"
            item.isNavigational = true
            
            if var topController = window?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                
                if !(topController is SplitViewController) {
                    item.target = nil
                    item.action = nil
                }
            } else {
                item.target = nil
                item.action = nil
            }
            
            return item
        case .init("newProject"):
            let item = NSMenuToolbarItem(itemIdentifier: itemIdentifier)
            item.image = UIImage(systemName: "plus")
            
            item.itemMenu = UIMenu(title: "New Project", children: [
                UIAction(title: "Mesh Gradient", handler: { [weak self] action in
                    if let navigationController = self?.window?.rootViewController as? UINavigationController, let projectNavigator = navigationController.topViewController as? ProjectNavigatorViewController {
                        projectNavigator.createDocument()
                    }
                }),
                UIAction(title: "3D Scene", state: .off, handler: { action in
                })
            ])
            
            if var topController = window?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                
                if (topController is SplitViewController) {
                    item.target = nil
                    item.action = nil
                }
            }
            
            return item
        case .init("export"):
            let button = UIBarButtonItem()
            button.image = UIImage(systemName: "square.and.arrow.up")
            button.action = #selector(export)
            button.target = self
            
            let item = NSToolbarItem(itemIdentifier: itemIdentifier, barButtonItem: button)
            item.label = "Export"
            
            if var topController = window?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                
                if !(topController is SplitViewController) {
                    item.target = nil
                    item.action = nil
                }
            } else {
                item.target = nil
                item.action = nil
            }
            
            return item
        default:
            return NSToolbarItem(itemIdentifier: itemIdentifier)
        }
    }
    
    func updateToolbar() {
        guard let toolbar = window?.windowScene?.titlebar?.toolbar else { return }
        for i in 0..<toolbar.items.count {
            let item = toolbar.items[i]
            toolbar.removeItem(at: i)
            toolbar.insertItem(withItemIdentifier: item.itemIdentifier, at: i)
        }
    }
}
#endif
