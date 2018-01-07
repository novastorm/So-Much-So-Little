//
//  CloudKitClient+Convenience.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/17/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CloudKit

extension CloudKitClient {
    
    // MARK: - Index method
    
    /// Performs a task using `database` that retrieves the Activity objects, and calls a handler upon completion.
    static func getActivityList(using database: CKDatabase = privateDatabase, completionHandler: @escaping (_ activityList: [CKRecord]?, _ error: Error?) -> Void) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: RecordType.Activity.rawValue, predicate: predicate)
        
        database.perform(query, inZoneWith: nil) { (results, error) in
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }

            completionHandler(results, nil)
        }
    }
    
    // MARK: - Show method
    
    static func getActivity(_ recordIdString: String, using database: CKDatabase = privateDatabase, completionHandler: @escaping (_ activity: CKRecord?, _ error: Error?) -> Void) {
    
        let recordId = CKRecordID(recordName: recordIdString)
        
        privateDatabase.fetch(withRecordID: recordId) { (record, error) in
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            completionHandler(record, nil)
        }
    }
    
    
    // MARK: - Store and update method
    
    static func storeActivity(_ activity: CKRecord, using database: CKDatabase = privateDatabase, completionHandler: @escaping(_ activity: CKRecord?, _ error: Error?) -> Void) {
        
        let modifyRecordsOperation = CKModifyRecordsOperation()
        modifyRecordsOperation.database = database
        modifyRecordsOperation.recordsToSave = [activity]
        
        modifyRecordsOperation.perRecordCompletionBlock = { (ckRecord, error) in
            guard error == nil else {
                print(error!)
                return
            }
            print("Store Activity record")
        }
        modifyRecordsOperation.modifyRecordsCompletionBlock = { (savedRecordList, deletedRecordIDList, error ) in
            completionHandler(savedRecordList?.first, error)
        }
        modifyRecordsOperation.start()
    }
    
    
//    // MARK: - Destroy method
//    
//    static func deleteActivity(_ recordIdString: String, completionHandler: @escaping (_ activity: CKRecord?, _ error: Error?) -> Void) {
//        
//    }
}
