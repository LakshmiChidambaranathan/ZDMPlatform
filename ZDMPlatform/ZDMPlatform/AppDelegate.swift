//
//  AppDelegate.swift
//  ZDMPlatform
//
//  Created by lakshmi-12493 on 22/09/23.
//

import UIKit
import CoreData
import ZohoDeskPortalAPIKit
import ZohoDeskPortalConfiguration
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        ZDMASAP.setupSDK(with: .portalSDKNew)
        ZohoDeskPortalKit.isLogEnabled = true
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "ZDMDemoApp")
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

}

enum ASAPConfiguration {
    case singleDept, deskMobile, corp, portalSDK, gcPlatformiOS, deskMobileNew, portalSDKNew
}

final class ZDMASAP {
    
    struct Credentials {
        var appId: String
        var orgId: String
        var bundleId: String
    }
    
    class func setupSDK(with config : ASAPConfiguration) {
        var credentials : Credentials
        switch config {
        case .singleDept:
            credentials = Credentials(appId: "edbsn4d60871cfc4c4a12f9cf3012b35217211795d8154c34fd723e34abcb65fccc19", orgId: "648638721", bundleId: "deskexmaple.zoho.com.deskexampleapp")
        case .deskMobile:
            credentials = Credentials(appId: "b10c3c638547955c73abf2fc9f38cc75f57d9b02e22471ff", orgId: "648638721", bundleId: "com.portalDemo.app")
        case .corp:
            credentials = Credentials(appId: "edbsne2cad5875cf6860518b4caabe63e9543", orgId: "4241905", bundleId: "com.desk.sdkdemo.zohocorp")
        case .portalSDK:
            credentials = Credentials(appId: "edbsna4c72ecf4eb28b468bf19578a6457af019184dcf5f57b8992cc84599ef0992b3", orgId: "695259828", bundleId: "com.portalDemo.app")
        case .gcPlatformiOS :
            credentials = Credentials(appId: "edbsn3e634a3215319385dfde58ab8ab9c87a2b350c4af59f4171efbee708ed84a9fe", orgId: "695259828", bundleId: "com.demo.gc.platform")
        case .deskMobileNew:
            credentials = Credentials(appId: "edbsn8feff784431f96819974766bcb79c45e37ddfe79550da844c1dc28672f9d5d79", orgId: "648638721", bundleId: "com.zoho.desk.asapsdk")
        case .portalSDKNew :
            credentials = Credentials(appId: "edbsnea3ab80ec51a7ca423e3127aec4de23959f13baf07d643dad55d14ec29fc3e67", orgId: "695259828", bundleId: "com.zoho.desk.asapsdk")
        }
        if !credentials.bundleId.isEmpty {
            PNConstants.bundleName = credentials.bundleId
        }
        ZohoDeskPortalKit.initialize(orgID: credentials.orgId, appID: credentials.appId)
    }
}
