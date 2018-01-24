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
    
    static func getProjectList(using database: CKDatabase = privateDatabase, _ completionHandler: @escaping (_ projectList: [CKRecord]?, _ error: Error?) -> Void) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: RecordType.Project.rawValue, predicate: predicate)
        
        database.perform(query, inZoneWith: nil) { (results, error) in
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            completionHandler(results, nil)
        }
    }
    
    // MARK: - Show method
    
    static func getProject(_ recordIdString: String, completionHandler: @escaping (_ activity: CKRecord?, _ error: Error?) -> Void) {
    
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
    
    static func storeProject(_ project: CKRecord, using database: CKDatabase = privateDatabase, completionHandler: @escaping(_ project: CKRecord?, _ error: Error?) -> Void) {

        let modifyRecordsOperation = CKModifyRecordsOperation()
        modifyRecordsOperation.database = database
        modifyRecordsOperation.recordsToSave = [project]
        
        modifyRecordsOperation.perRecordCompletionBlock = { (ckRecord, error) in
            guard error == nil else {
                print(error!)
                return
            }
//            print("Store Project record")
        }
        modifyRecordsOperation.modifyRecordsCompletionBlock = { (savedRecordList, deletedRecordIDList, error ) in
            completionHandler(savedRecordList?.first!, error)
        }
        modifyRecordsOperation.start()
    }
    
    
    // MARK: - Destroy method
    
    
    static func destroyProject(_ project: CKRecord, using database: CKDatabase = privateDatabase, completionHandler: @escaping(_ project: CKRecordID?, _ error: Error?) -> Void) {
        
        let modifyRecordsOperation = CKModifyRecordsOperation()
        modifyRecordsOperation.database = database
        modifyRecordsOperation.recordIDsToDelete = [project.recordID]
        
        modifyRecordsOperation.perRecordCompletionBlock = { (ckRecord, error) in
            guard error == nil else {
                print(error!)
                return
            }
//            print("Store Project record")
        }
        modifyRecordsOperation.modifyRecordsCompletionBlock = { (savedRecordList, deletedRecordIDList, error ) in
            completionHandler(deletedRecordIDList?.first!, error)
        }
        modifyRecordsOperation.start()
    }
}
