//
//  CloudKitClient+CoreData.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/24/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

extension CloudKitClient {
    
    
    // MARK: - Core Data convenience methods
    
//    static var coreDataStack: CoreDataStack {
//        return dependencies.coreDataStack
//    }
    
    var mainContext: NSManagedObjectContext {
        return coreDataStack.mainContext
    }
    
    // MARK: - Sync methods
    
    func importDefaultRecords() {
        
        guard ubiquityIdentityToken != nil else {
            print("Log into iCloud for remote sync")
            return
        }
        
        // TODO: check if network connection exists.
        
        let group = DispatchGroup()
        
        var ckProjectList = [CKRecord]()
        var ckActivityList = [CKRecord]()
        
        group.enter()
        getProjectList(using: publicDatabase) { (results, error) in
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
        getActivityList(using: publicDatabase) { (results, error) in
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
//                print("Import: Project")
                _ = Project(insertInto: self.coreDataStack.mainContext, with: ckProject)
            }
            
            for ckActivity in ckActivityList {
//                print("Import: Activity")
                let activity = Activity(insertInto: self.mainContext, with: ckActivity)
                if let projectRef = ckActivity[Activity.Keys.Project] as? CKReference {
                    
                    let ckProject = ckProjectList.filter({ (ckRecord) -> Bool in
                        return ckRecord.recordID == projectRef.recordID
                    }).first!
                    
                    let fetchRequest: NSFetchRequest<Project> = Project.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "encodedCKRecord = %@", ckProject.encodedCKRecordSystemFields as NSData)
                    
                    let projectList: [Project] = try! self.mainContext.fetch(fetchRequest)
                    activity.project = projectList.first
                }
            }
            
            self.coreDataStack.saveMainContext()
        }
    }
    
    func importRecords() {
//        print("Cloud Kit: Import Records")
        let group = DispatchGroup()
        
        var ckProjectList = [CKRecord]()
        var ckActivityList = [CKRecord]()
        
        group.enter()
        getProjectList { (results, error) in
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
        getActivityList { (results, error) in
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
            
//            print("Import: notify")
            for ckProject in ckProjectList {
//                print("Import: Project")
                let fetchProjectRequest: NSFetchRequest<Project> = Project.fetchRequest()
                fetchProjectRequest.predicate = NSPredicate(format: "ckRecordIdName = %@", ckProject.recordID.recordName)
                fetchProjectRequest.sortDescriptors = []
                
                let fetchedProjectResults = try! self.mainContext.fetch(fetchProjectRequest)
//                print(fetchedProjectResults)

                switch fetchedProjectResults.count {
                case 1:
                    let project = fetchedProjectResults.first!
                    project.encodedCKRecord = ckProject.encodedCKRecordSystemFields
                case 0:
                    let project = Project(insertInto: self.mainContext, with: ckProject)
                    print(project)
                default:
                    fatalError("Unknown state fetching local projects")
                }
            }
            
            for ckActivity in ckActivityList {
//                print("Import: Activity")

                let fetchActivityRequest: NSFetchRequest<Activity> = Activity.fetchRequest()
                fetchActivityRequest.predicate = NSPredicate(format: "ckRecordIdName = %@", ckActivity.recordID.recordName)
                fetchActivityRequest.sortDescriptors = []
                
                let fetchedActivityResults = try! self.mainContext.fetch(fetchActivityRequest)
//                print(fetchedActivityResults)

                switch fetchedActivityResults.count {
                case 1:
                    let activity = fetchedActivityResults.first!
                    activity.encodedCKRecord = ckActivity.encodedCKRecordSystemFields
                case 0:
                    let activity = Activity(insertInto: self.mainContext, with: ckActivity)
                    if let projectRef = ckActivity[Activity.Keys.Project] as? CKReference {
                        
                        let ckProject = ckProjectList.filter({ (ckRecord) -> Bool in
                            return ckRecord.recordID == projectRef.recordID
                        }).first!
                        
                        let fetchProjectRequest: NSFetchRequest<Project> = Project.fetchRequest() as NSFetchRequest
                        fetchProjectRequest.predicate = NSPredicate(format: "encodedCKRecord = %@", ckProject.encodedCKRecordSystemFields as NSData)
                        
                        let fetchedProjectResults = try! self.mainContext.fetch(fetchProjectRequest)
                        activity.project = fetchedProjectResults.first
                    }
//                    print(activity)
                default:
                    fatalError("Unknown state fetching local activities.")
                }
            }
            
            self.coreDataStack.saveMainContext()
        }
    }
    
    /**
     Import Cloud Kit Project records into Core Data database
     
     - ToDo: test to do
     */
    func importProjectList() {
        let group = DispatchGroup()
        
        var ckProjectList = [CKRecord]()
        
        group.enter()
        getProjectList { (results, error) in
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
                _ = Project(insertInto: self.mainContext, with: ckProject)
            }
            
            self.coreDataStack.saveMainContext()
        }
    }
    
    func importActivityList() {
        
    }
    
    func exportRecords() {
        
    }
    
    func exportProjectList() {
        
    }
    
    func exportActivityList() {
        
    }
    
    func processUnsynchedRecords() {
        
    }
}
