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
    func getActivityList(
        using database: CKDatabase = CKContainer.default().privateCloudDatabase,
        completionHandler: @escaping (_ activityList: [CKRecord]?, _ error: Error?) -> Void
        ) {
        
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
    
    func getActivity(
        _ recordIdString: String,
        using database: CKDatabase = CKContainer.default().privateCloudDatabase,
        completionHandler: @escaping (_ activity: CKRecord?, _ error: Error?) -> Void
        ) {
    
        let recordId = CKRecord.ID(recordName: recordIdString)
        
        privateDatabase.fetch(withRecordID: recordId) { (record, error) in
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            completionHandler(record, nil)
        }
    }
    
    
    // MARK: - Store and update method
    
    func storeActivity(
        _ activity: CKRecord,
        using database: CKDatabase = CKContainer.default().privateCloudDatabase,
        completionHandler: @escaping(_ activity: CKRecord?, _ error: Error?) -> Void
        ) {
        
        let modifyRecordsOperation = CKModifyRecordsOperation()
        modifyRecordsOperation.database = database
        modifyRecordsOperation.recordsToSave = [activity]
        
        modifyRecordsOperation.perRecordCompletionBlock = { (ckRecord, error) in
            guard error == nil else {
                print(error!)
                return
            }
//            print("Store Activity record")
        }
        modifyRecordsOperation.modifyRecordsCompletionBlock = { (savedRecordList, deletedRecordIDList, error ) in
            completionHandler(savedRecordList?.first, error)
        }
        modifyRecordsOperation.start()
    }
    
    
    // MARK: - Destroy method
    
    func destroyActivity(
        _ activity: CKRecord,
        using database: CKDatabase = CKContainer.default().privateCloudDatabase,
        completionHandler: @escaping(_ activity: CKRecord.ID?, _ error: Error?) -> Void
        ) {
        
        let modifyRecordsOperation = CKModifyRecordsOperation()
        modifyRecordsOperation.database = database
        modifyRecordsOperation.recordIDsToDelete = [activity.recordID]
        
        modifyRecordsOperation.perRecordCompletionBlock = { (ckRecord, error) in
            guard error == nil else {
                print(error!)
                return
            }
//            print("Destroy Activity record")
        }
        
        modifyRecordsOperation.modifyRecordsCompletionBlock = { (savedRecordList, deletedRecordIDList, error ) in
            completionHandler(deletedRecordIDList?.first, error)
        }
        modifyRecordsOperation.start()
    }
}
