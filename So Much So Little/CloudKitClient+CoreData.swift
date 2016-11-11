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
            
            for project in results! {
                let newProject = CKRecord(recordType: project.recordType, recordID: project.recordID)

                for key in project.allKeys() {
                    newProject[key] = project[key]
                }
                ckProjectList.append(newProject)
            }
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
            
            for activity in results! {
                let newActivity = CKRecord(recordType: activity.recordType, recordID: activity.recordID)
                
                for key in activity.allKeys() {
                    newActivity[key] = activity[key]
                }
                
                ckActivityList.append(newActivity)
            }
        }
        
        group.notify(queue: .main) {
            for ckProject in ckProjectList {
                _ = Project(context: CoreDataStackManager.mainContext, ckRecord: ckProject)
            }
            
            for ckActivity in ckActivityList {
                let activity = Activity(context: CoreDataStackManager.mainContext, ckRecord: ckActivity)
                if let projectRef = ckActivity[Activity.Keys.Project] as? CKReference {
                    
                    let ckProject = ckProjectList.filter({ (ckRecord) -> Bool in
                        return ckRecord.recordID == projectRef.recordID
                    }).first!
                    
                    let fetchRequest = Project.fetchRequest() as NSFetchRequest
                    fetchRequest.predicate = NSPredicate(format: "ckRecordID = %@", ckProject.encodedCKRecordSystemFields as NSData)
                    
                    let projectList = try! CoreDataStackManager.mainContext.fetch(fetchRequest)
                    activity.project = projectList.first
                }
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
