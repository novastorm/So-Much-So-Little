//
//  CloudKitClient+Convenience.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/17/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CloudKit
import CoreData
import Foundation

extension CloudKitClient {
    
//    static func storeRecords(_ records: [CKRecord], using database: CKDatabase = privateDatabase, completionHandler: @escaping(_ record: CKRecord?, _ error: Error?) -> Void) {
//        
//        let modifyRecordsOperation = CKModifyRecordsOperation()
//        modifyRecordsOperation.database = database
//        modifyRecordsOperation.recordsToSave = records
//        
//        modifyRecordsOperation.perRecordCompletionBlock = { (ckRecord, error) in
//            guard error == nil else {
//                print("perRecordCompletionBlock", error!)
//                return
//            }
//            print("Store record")
//        }
//        modifyRecordsOperation.modifyRecordsCompletionBlock = { (savedRecordList, deletedRecordIDList, error ) in
//            guard error == nil else {
//                print("modifyRecordsCompletionBlock", error!)
//                completionHandler(nil, error)
//                return
//            }
//            completionHandler(savedRecordList?.first!, error)
//        }
//        modifyRecordsOperation.start()
//    }
    
    static func storeRecords(using database: CKDatabase = privateDatabase, context: NSManagedObjectContext, completionHandler: @escaping(_ success: Bool, _ error: Error?) -> Void) {
        
//        let insertedObjects = context.insertedObjects
//        let updatedObjects = context.updatedObjects
        let modifiedObjects = context.insertedObjects.union(context.updatedObjects)
        let deletedObjects = context.deletedObjects
        
        let modifyRecordsOperation = CKModifyRecordsOperation()
        modifyRecordsOperation.database = database
        
        // FIXME: join the two sets for ckloudkit processing
        modifyRecordsOperation.recordsToSave = modifiedObjects.flatMap { (record) -> CKRecord? in
            guard let record = record as? CloudKitManagedObject else {
                return nil
            }

            return record.cloudKitRecord
        }
        
        // FIXME: map ckrecordId for clokudkit processing
        modifyRecordsOperation.recordIDsToDelete = deletedObjects.flatMap { (record) -> CKRecordID? in
            return nil
        }
        
        modifyRecordsOperation.perRecordCompletionBlock = { (ckRecord, error) in
            guard error == nil else {
                print("perRecordCompletionBlock", error!)
                return
            }
            
            let record = modifiedObjects.first() { (record) -> Bool in
                let record = record as! CloudKitManagedObject
                var result = false
                context.performAndWait {
                    result = record.ckRecordIdName == ckRecord.recordID.recordName
                }
                return result
            } as! CloudKitManagedObject
            
            context.performAndWait {
                record.encodedCKRecord = ckRecord.encodedCKRecordSystemFields
            }
            
            print("Store record")
        }
        
        modifyRecordsOperation.modifyRecordsCompletionBlock = { (savedRecordList, deletedRecordIDList, error ) in
            guard error == nil else {
                print("modifyRecordsCompletionBlock", error!)
                return
            }
            print("Store records complete")
        }

        modifyRecordsOperation.start()
        
        completionHandler(true, nil)
    }
    
    // MARK: - Destroy method
    
    static func deleteRecord(_ recordIdString: String, completionHandler: @escaping (_ activity: CKRecord?, _ error: Error?) -> Void) {
        
    }
}
