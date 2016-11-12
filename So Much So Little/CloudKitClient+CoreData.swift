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
            
            let modifyRecordsOperation = CKModifyRecordsOperation()
            modifyRecordsOperation.database = privateDatabase
            modifyRecordsOperation.recordsToSave = ckActivityList + ckProjectList
            
            modifyRecordsOperation.perRecordCompletionBlock = { (ckRecord, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                print("Store record")
            }
            modifyRecordsOperation.modifyRecordsCompletionBlock = { (savedRecordList, deletedRecordIDList, error ) in
                print("Import initial public records to private ckDatabase.")
            }
            
            modifyRecordsOperation.start()
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
