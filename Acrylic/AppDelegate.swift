//
//  AppDelegate.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import UIKit
import CoreData
import UniformTypeIdentifiers
import TelemetryClient
import MessageUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MFMailComposeViewControllerDelegate {

    static var isCloudFolder: Bool = true
    static var documentsFolder: URL = {
        if let cloudFolder = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
            isCloudFolder = true
            return cloudFolder
        } else {
            isCloudFolder = false
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        }
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let configuration = TelemetryManagerConfiguration(
            appID: "B278B666-F5F1-4014-882C-5403DA338EE5")
        TelemetryManager.initialize(with: configuration)
        
        if !FileManager.default.fileExists(atPath: Self.documentsFolder.path) {
            do {
                try FileManager.default.createDirectory(at: Self.documentsFolder, withIntermediateDirectories: true)
            } catch {
                print(error)
            }
        }
        
        print(Self.documentsFolder.path)
        
        TelemetryManager.send("applicationDidFinishLaunching")
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        if options.userActivities.first?.activityType == "editor" {
            let config = UISceneConfiguration(name: "Editor Scene Configuration", sessionRole: connectingSceneSession.role)
            config.delegateClass = EditorSceneDelegate.self
            return config
        } else {
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        }
    }
    
    func application(_ application: UIApplication, shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
        return true
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "Acrylic")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIDevice.current.userInterfaceIdiom == .phone ? .portrait : .landscape
    }
    
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        builder.remove(menu: .edit)
        builder.remove(menu: .format)
        
        let exportCommand = UIKeyCommand(input: "E", modifierFlags: [.command], action: #selector(export))
        exportCommand.title = "Export..."
        let exportMenu = UIMenu(title: "Export...", identifier: UIMenu.Identifier("export"), options: .displayInline, children: [exportCommand])
        builder.insertSibling(exportMenu, afterMenu: .newScene)
    }
    
    @objc func export() {
        UIApplication.shared.connectedScenes
            .compactMap({ $0.delegate as? EditorDelegate })
            .first(where: { $0.window?.isKeyWindow ?? false })?
            .export()
    }
    
    @objc func newMesh() { }
    
#if targetEnvironment(macCatalyst)
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(showHelp(_:)) || action == #selector(export)
    }
    
    @objc func showHelp(_ sender: Any?) {
        let projectNavigatorScene = UIApplication.shared.connectedScenes
            .compactMap({ $0.delegate as? SceneDelegate })
            .first(where: { $0.window?.isKeyWindow ?? false })?
            .window
        
        let editorScene = UIApplication.shared.connectedScenes
            .compactMap({ $0.delegate as? EditorDelegate })
            .first(where: { $0.window?.isKeyWindow ?? false })?
            .window
        
        if var topController = (projectNavigatorScene ?? editorScene)?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["hi@ethanlipnik.com"])
                mail.setSubject("Acrylic Support")
                mail.setMessageBody("<p><strong>OS Version:</strong> macOS \(UIDevice.current.systemVersion)</p><p><strong>App Version:</strong> \(Bundle.main.appVersionLong)</p><p><strong>Build Number:</strong> \(Bundle.main.appBuild)</p>", isHTML: true)
                
                topController.present(mail, animated: true)
            } else {
                let alertController = UIAlertController(title: "Can't send mail", message: "No mail app found. Please email hi@ethanlipnik.com.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .cancel))
                topController.present(alertController, animated: true)
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
#endif
}

extension Bundle {
    public var appName: String { getInfo("CFBundleName")  }
    public var displayName: String {getInfo("CFBundleDisplayName")}
    public var language: String {getInfo("CFBundleDevelopmentRegion")}
    public var identifier: String {getInfo("CFBundleIdentifier")}
    public var copyright: String {getInfo("NSHumanReadableCopyright").replacingOccurrences(of: "\\\\n", with: "\n") }
    
    public var appBuild: String { getInfo("CFBundleVersion") }
    public var appVersionLong: String { getInfo("CFBundleShortVersionString") }
    
    fileprivate func getInfo(_ str: String) -> String { infoDictionary?[str] as? String ?? "⚠️" }
}
