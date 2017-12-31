//
//  AppDelegate.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/14/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var connectionMonitor: ConnectionMonitor!

    var debugWithoutNetwork: Bool = false

    struct UserDefaultKeys {
        static let HasLaunchedBefore = "hasLaunchedBefore"
    }

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        connectionMonitor = ConnectionMonitor.init(hostname: "8.8.8.8")

        checkIfFirstLaunch()
        CoreDataStackManager.shared.autoSave(60)
        CloudKitClient.importRecords()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

        CoreDataStackManager.shared.saveMainContext()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        CoreDataStackManager.shared.saveMainContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

        // TODO: Sync cloud kit data.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

    func checkIfFirstLaunch() {
        if !UserDefaults.standard.bool(forKey: UserDefaultKeys.HasLaunchedBefore) {
            UserDefaults.standard.set(true, forKey: UserDefaultKeys.HasLaunchedBefore)
        }
    }
}

