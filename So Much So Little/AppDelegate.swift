//
//  AppDelegate.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/14/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    enum Views: String {
        case
        ActivityTimer,
        Main
    }
    
//    var connectionMonitor: ConnectionMonitor!

    struct UserDefaultKeys {
        static let HasLaunchedBefore = "hasLaunchedBefore"
    }

    var window: UIWindow?

    var coreDataStack: CoreDataStack = CoreDataStack_v1(name: "So_Much_So_Little")!
    var cloudKitClient: CloudKitClient = CloudKitClient()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        connectionMonitor = ConnectionMonitor.init(hostname: "8.8.8.8")

//        coreDataStack.cloudKitClient = cloudKitClient
//        cloudKitClient.coreDataStack = coreDataStack
        
        checkIfFirstLaunch()
        coreDataStack.autoSave(60)
        
        let projectActivityDataSource = ProjectActivityCloudKitClient()
        projectActivityDataSource.importRecords(completionHandler: processImportedCKRecords(_:_:))
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

        coreDataStack.saveMainContext()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        coreDataStack.saveMainContext()
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
    
    func processImportedCKRecords(_ results: [String:[CKRecord]]?, _ error: Error?) {
        
        guard error == nil else {
            print("Error retrieving from Cloud Kit")
            return
        }
        
        guard
            let ckProjectList = results?["ckProjectList"],
            let ckActivityList = results?["ckActivityList"]
        else {
            print("Error parsing cloud kit import results")
            return
        }
        
        let mainContext = coreDataStack.mainContext
        
//        print("Import: notify")
        for ckProject in ckProjectList {
//            print("Import: Project")
            let fetchProjectRequest: NSFetchRequest<Project> = Project.fetchRequest()
            fetchProjectRequest.predicate = NSPredicate(format: "ckRecordIdName = %@", ckProject.recordID.recordName)
            fetchProjectRequest.sortDescriptors = []
            
            let fetchedProjectResults = try! mainContext.fetch(fetchProjectRequest)
//            print(fetchedProjectResults)
            
            switch fetchedProjectResults.count {
            case 1:
                let project = fetchedProjectResults.first!
                project.encodedCKRecord = ckProject.encodedCKRecordSystemFields
            case 0:
                Project(insertInto: mainContext, with: ckProject)
            default:
                fatalError("Unknown state fetching local projects")
            }
        }
        
        for ckActivity in ckActivityList {
//            print("Import: Activity")
            
            let fetchActivityRequest: NSFetchRequest<Activity> = Activity.fetchRequest()
            fetchActivityRequest.predicate = NSPredicate(format: "ckRecordIdName = %@", ckActivity.recordID.recordName)
            fetchActivityRequest.sortDescriptors = []
            
            let fetchedActivityResults = try! mainContext.fetch(fetchActivityRequest)
//            print(fetchedActivityResults)
            
            switch fetchedActivityResults.count {
            case 1:
                let activity = fetchedActivityResults.first!
                activity.encodedCKRecord = ckActivity.encodedCKRecordSystemFields
            case 0:
                let activity = Activity(insertInto: mainContext, with: ckActivity)
                if let projectRef = ckActivity[Activity.Keys.Project] as? CKRecord.Reference {
                    
                    let ckProject = ckProjectList.filter({ (ckRecord) -> Bool in
                        return ckRecord.recordID == projectRef.recordID
                    }).first!
                    
                    let fetchProjectRequest: NSFetchRequest<Project> = Project.fetchRequest() as NSFetchRequest
                    fetchProjectRequest.predicate = NSPredicate(format: "encodedCKRecord = %@", ckProject.encodedCKRecordSystemFields as NSData)
                    
                    let fetchedProjectResults = try! mainContext.fetch(fetchProjectRequest)
                    activity.project = fetchedProjectResults.first
                }
//                print(activity)
            default:
                fatalError("Unknown state fetching local activities.")
            }
        }
        
//        self.coreDataStack.saveMainContext()
        
    }
}

