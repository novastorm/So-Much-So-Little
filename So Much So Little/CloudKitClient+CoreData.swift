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
        
        guard ubiquityIdentityToken != nil else {
            print("Log into iCloud for remote sync")
            return
        }
        
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

            let projectFetchRequest: NSFetchRequest<Project> = Project.fetchRequest()
            let projectList = try! CoreDataStackManager.mainContext.fetch(projectFetchRequest)
            let activityFetchRequest: NSFetchRequest<Activity> = Activity.fetchRequest()
            let activityList = try! CoreDataStackManager.mainContext.fetch(activityFetchRequest)

            for project in projectList {
                project.ckRecordID = nil
            }
            for activity in activityList {
                activity.ckRecordID = nil
            }
            
            CoreDataStackManager.saveMainContext()
        }
    }
    
    static func importRecords() {
        
    }
    
    static func exportRecords() {

    }
    
    static func pushProjectList() {

    }
    
    static func pushActivityList() {
        
    }
    
    static func pullProjectList() {
        
    }
    
    static func pullActivityList() {
        
    }
}
