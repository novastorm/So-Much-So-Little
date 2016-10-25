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
            for ckProject in ckProjectList! {
                print(ckProject)
                _ = Project(context: CoreDataStackManager.mainContext, ckRecord: ckProject)
            }
            
            for ckActivity in ckActivityList! {
                print(ckActivity)
                let activity = Activity(context: CoreDataStackManager.mainContext, ckRecord: ckActivity)
                if let projectRef = ckActivity[Activity.Keys.Project] as? CKReference {
                    print(projectRef.recordID.recordName)
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
