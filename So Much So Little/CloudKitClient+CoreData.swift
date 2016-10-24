//
//  CloudKitClient+CoreData.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/24/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CloudKit
import CoreData

extension CloudKitClient {
    
    
    // MARK: - Core Data convenience methods
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.mainContext
    }

    // MARK: - Sync methods
    
    static func importDefaultRecords() {
//        let projectQueue = DispatchQueue(label: "com.4mfd.project")
//        let activityQueue = DispatchQueue(label: "com.4mfd.activity")
        
        let group = DispatchGroup()
        
        var ckProjectList: [CKRecord]?
        var ckActivityList: [CKRecord]?
        
        group.enter()
        CloudKitClient.getPublicProjectList { (results, error) in
            guard error == nil else {
                print(error!)
                group.leave()
                return
            }
            ckProjectList = results
            group.leave()
        }
        
        group.enter()
        CloudKitClient.getPublicActivityList { (results, error) in
            guard error == nil else {
                print(error!)
                group.leave()
                return
            }
            ckActivityList = results
            group.leave()
        }
        
        group.notify(queue: .main) {
            for project in ckProjectList! {
                print(project)
                let _ = Project(context: CoreDataStackManager.mainContext, ckRecord: project)
            }
            
            for activity in ckActivityList! {
                print(activity)
                let _ = Activity(context: CoreDataStackManager.mainContext, ckRecord: activity)
            }
            
            CoreDataStackManager.saveMainContext()
        }
    }
    
    static func syncProjectList() {
        
    }
    
    static func syncActivityList() {
        
    }
}
