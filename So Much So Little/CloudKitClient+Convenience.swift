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
    
    static func storeRecords(using database: CKDatabase = privateDatabase, context: NSManagedObjectContext, completionHandler: @escaping(_ success: Bool, _ error: Error?) -> Void) {
        
        let modifiedObjects = context.insertedObjects.union(context.updatedObjects)
        let deletedObjects = context.deletedObjects
        
        let modifyRecordsOperation = CKModifyRecordsOperation()
        modifyRecordsOperation.database = database
        
        modifyRecordsOperation.recordsToSave = modifiedObjects.flatMap { (record) -> CKRecord? in
            guard let record = record as? CloudKitManagedObject else {
                return nil
            }

            return record.cloudKitRecord
        }
        
        modifyRecordsOperation.recordIDsToDelete = deletedObjects.flatMap { (record) -> CKRecordID? in
            guard let record = record as? CloudKitManagedObject else {
                return nil
            }
            
            return CKRecord.decodeCKRecordSystemFields(from: record.encodedCKRecord!).recordID
        }
        
        modifyRecordsOperation.perRecordCompletionBlock = { (ckRecord, error) in
            guard error == nil else {
                print("perRecordCompletionBlock", error!)
                completionHandler(false, error)
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
                completionHandler(false, error)
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
