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
    
    var mainContext: NSManagedObjectContext {
        return CoreDataStackManager.mainContext
    }

    // MARK: - Sync methods
    
    static func importDefaultRecords() {
        
        // TODO: check if network connection exists.

        let group = DispatchGroup()
        
        var ckProjectList = [CKRecord]()
        var ckActivityList = [CKRecord]()
        
        group.enter()
        CloudKitClient.getPublicProjectList { (results, error) in
            defer {
                group.leave()
            }
            guard error == nil else {
                print(error!)
                return
            }
            ckProjectList = results!
        }
        
        group.enter()
        CloudKitClient.getPublicActivityList { (results, error) in
            defer {
                group.leave()
            }
            guard error == nil else {
                print(error!)
                return
            }
            ckActivityList = results!
        }
        
        group.notify(queue: .main) {
            for ckProject in ckProjectList {
                _ = Project(context: CoreDataStackManager.mainContext, ckRecord: ckProject)
            }
            
            for ckActivity in ckActivityList {
                let activity = Activity(context: CoreDataStackManager.mainContext, ckRecord: ckActivity)
                if let projectRef = ckActivity[Activity.Keys.Project] as? CKReference {
                    // Fetch from Core Data the project with ckRecordID string
                    let projectFetchRequest: NSFetchRequest<Project> = Project.fetchRequest()
                    projectFetchRequest.predicate = NSPredicate(format: "ckRecordID = %@", projectRef.recordID.recordName)
                    let project = (try! CoreDataStackManager.mainContext.fetch(projectFetchRequest)).first
                    activity.project = project
                }
            }
            
            CoreDataStackManager.saveMainContext()
        }
    }
    
    static func syncProjectList() {
        
    }
    
    static func syncActivityList() {
        
    }
}
