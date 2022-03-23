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
    
    var meshService = MeshService()


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = SplitViewController(style: .doubleColumn)
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
        meshService.isExporting.toggle()
        
        meshService.render { [weak self] renderImage in
            if var topController = self?.window?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                let vc = ExportViewController(renderImage: renderImage)
//                let vc = UIHostingController(rootView: ExportView(renderImage: renderImage))
                
                topController.present(vc, animated: true)
            }
        }
    }
}

#if targetEnvironment(macCatalyst)
extension SceneDelegate: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.toggleSidebar, .init("export")]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .init("export"):
            let button = UIBarButtonItem()
            button.image = UIImage(systemName: "square.and.arrow.up")
            button.action = #selector(export)
            button.target = self
            
            let item = NSToolbarItem(itemIdentifier: itemIdentifier, barButtonItem: button)
            item.label = "Export"
//            let item = NSMenuToolbarItem(itemIdentifier: itemIdentifier, barButtonItem: button)
//            item.itemMenu = UIMenu(title: "Export Options", identifier: .init("exportOptions"), children: [
//                UIAction(title: "4k", identifier: .init("export4k"), handler: { action in
//                    self.export()
//                }),
//                UIAction(title: "2k", identifier: .init("export4k"), handler: { action in
//                    self.export()
//                }),
//                UIAction(title: "1080p", identifier: .init("export4k"), handler: { action in
//                    self.export()
//                }),
//                UIAction(title: "720p", identifier: .init("export4k"), handler: { action in
//                    self.export()
//                })
//            ])
            
            return item
        default:
            return NSToolbarItem(itemIdentifier: itemIdentifier)
        }
    }
}
#endif
