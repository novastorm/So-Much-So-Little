//
//  ActivityCloudKitClient.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/17/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CloudKit
import UIKit

class ActivityCloudKitClient {
    
    // MARK: - Properties
    
    var cloudKitClient: CloudKitClient!
    var publicCloudDatabase: CKDatabase {
        return cloudKitClient.publicCloudDatabase
    }
    var privateCloudDatabase: CKDatabase {
        return cloudKitClient.privateCloudDatabase
    }
    
    // MARK: - Initializers
    
    init(cloudKitClient: CloudKitClient = (UIApplication.shared.delegate as! AppDelegate).cloudKitClient) {
        self.cloudKitClient = cloudKitClient
    }
    
    
    // MARK: - Index method
    
    /// Performs a task using `database` that retrieves the Activity objects, and calls a handler upon completion.
    func getRecordList(
        usePublicDatabase: Bool = false,
        completionHandler: @escaping (_ results: [CKRecord]?, _ error: Error?) -> Void
        ) {

        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Activity.typeName, predicate: predicate)

        cloudKitClient.getRecordList(query: query, inZoneWith: nil, usePublicDatabase: usePublicDatabase, completionHandler: completionHandler)
    }
    
    // MARK: - Show method
    
    func getRecord(
        _ recordIdString: String,
        usePublicDatabase: Bool = false,
        completionHandler: @escaping (_ record: CKRecord?, _ error: Error?) -> Void
        ) {

        let recordId = CKRecord.ID(recordName: recordIdString)
        
        cloudKitClient.getRecord(
            byId: recordId,
            usePublicDatabase: usePublicDatabase,
            completionHandler: completionHandler)
    }
    
    
    // MARK: - Store and update method
    
    func store(
        _ activity: CKRecord,
        usePublicDatabase: Bool = false,
        completionHandler: @escaping(_ record: CKRecord?, _ error: Error?) -> Void
        ) {
        let database = usePublicDatabase ? publicCloudDatabase : privateCloudDatabase

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
    
    func destroy(
        _ activity: CKRecord,
        usePublicDatabase: Bool = false,
        completionHandler: @escaping(_ activity: CKRecord.ID?, _ error: Error?) -> Void
        ) {
        let database = usePublicDatabase ? publicCloudDatabase : privateCloudDatabase

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
