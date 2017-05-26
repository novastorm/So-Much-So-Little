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
        CloudKitClient.getProjectList(using: publicDatabase) { (results, error) in
            defer {
                group.leave()
            }
            guard error == nil else {
                print(error!)
                return
            }
            
            for project in results! {
                // FIXME: refactor to save a coredata object
                let newProject = CKRecord(recordType: project.recordType, recordID: project.recordID)
                
                for key in project.allKeys() {
                    newProject[key] = project[key]
                }
                ckProjectList.append(newProject)
            }
        }
        
        group.enter()
        CloudKitClient.getActivityList(using: publicDatabase) { (results, error) in
            defer {
                group.leave()
            }
            guard error == nil else {
                print(error!)
                return
            }
            
            for activity in results! {
                // FIXME: refactor to save a coredata object
                let newActivity = CKRecord(recordType: activity.recordType, recordID: activity.recordID)
                
                for key in activity.allKeys() {
                    newActivity[key] = activity[key]
                }
                
                ckActivityList.append(newActivity)
            }
        }
        
        group.notify(queue: .main) {
            for ckProject in ckProjectList {
                print("Import: Project")
                _ = Project(context: CoreDataStackManager.mainContext, ckRecord: ckProject)
            }
            
            for ckActivity in ckActivityList {
                print("Import: Activity")
                let activity = Activity(context: CoreDataStackManager.mainContext, ckRecord: ckActivity)
                if let projectRef = ckActivity[Activity.Keys.Project] as? CKReference {
                    
                    let ckProject = ckProjectList.filter({ (ckRecord) -> Bool in
                        return ckRecord.recordID == projectRef.recordID
                    }).first!
                    
                    let fetchRequest = Project.fetchRequest() as NSFetchRequest
                    fetchRequest.predicate = NSPredicate(format: "encodedCKRecord = %@", ckProject.encodedCKRecordSystemFields as NSData)
                    
                    let projectList = try! CoreDataStackManager.mainContext.fetch(fetchRequest)
                    activity.project = projectList.first
                }
            }
            
            CoreDataStackManager.saveMainContext()
        }
    }
    
    static func importRecords() {
        print("Cloud Kit: Import Records")
        let group = DispatchGroup()
        
        var ckProjectList = [CKRecord]()
        var ckActivityList = [CKRecord]()
        
        group.enter()
        CloudKitClient.getProjectList { (results, error) in
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
        CloudKitClient.getActivityList { (results, error) in
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
            print("Import: notify")
            for ckProject in ckProjectList {
                print("Import: Project")
                _ = Project(context: CoreDataStackManager.mainContext, ckRecord: ckProject)
            }
            
            for ckActivity in ckActivityList {
                print("Import: Activity")
                let activity = Activity(context: CoreDataStackManager.mainContext, ckRecord: ckActivity)
                if let projectRef = ckActivity[Activity.Keys.Project] as? CKReference {
                    
                    let ckProject = ckProjectList.filter({ (ckRecord) -> Bool in
                        return ckRecord.recordID == projectRef.recordID
                    }).first!
                    
                    let fetchRequest = Project.fetchRequest() as NSFetchRequest
                    fetchRequest.predicate = NSPredicate(format: "encodedCKRecord = %@", ckProject.encodedCKRecordSystemFields as NSData)
                    
                    let projectList = try! CoreDataStackManager.mainContext.fetch(fetchRequest)
                    activity.project = projectList.first
                }
            }
            
            CoreDataStackManager.saveMainContext()
        }
    }
    
    /**
     Import Cloud Kit Project records into Core Data database
     
     - ToDo: test to do
     */
    static func importProjectList() {
        let group = DispatchGroup()
        
        var ckProjectList = [CKRecord]()
        
        group.enter()
        CloudKitClient.getProjectList { (results, error) in
            defer {
                group.leave()
            }
            guard error == nil else {
                print(error!)
                return
            }
            
            ckProjectList = results!
        }
        
        group.notify(queue: .main)  {
            for ckProject in ckProjectList {
                // TODO: Check for existing record
                _ = Project(context: CoreDataStackManager.mainContext, ckRecord: ckProject)
            }
            
            CoreDataStackManager.saveMainContext()
        }
    }
    
    static func importActivityList() {
        
    }
    
    static func exportRecords() {
        
    }
    
    static func exportProjectList() {
        
    }
    
    static func exportActivityList() {
        
    }
}
