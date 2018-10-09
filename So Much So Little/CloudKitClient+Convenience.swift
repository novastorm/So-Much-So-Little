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

    /**
     Creates a task that retrieves the contents from the specified database based on the specified query, and calls a handler upon completion.
     
     - Parameters:
        - query: The query object containing the parameters for the search. This method throws an exception if this parameter is nil. For information about how to construct queries, see CKQuery.
        - zoneID: The ID of the zone to search. Search results are limited to records in the specified zone. Specify nil to search the default zone of the database.
        - completionHandler: The block to execute with the search results. Your block must be capable of running on any thread of the app and must take the following parameters:
        - usePublicDatabase: If true, use the public cloud database, otherwise use the private cloud database
        - results: An array containing zero or more CKRecord objects. The returned records correspond to the records in the specified zone that match the parameters of the query.
        - error: An error object, or nil if the query was completed successfully. Use the information in the error object to determine whether a problem has a workaround.
     */
    func getRecords(
        query: CKQuery,
        inZoneWith zoneID: CKRecordZone.ID? = nil,
        usePublicDatabase: Bool = false,
        completionHandler: @escaping (_ results: [CKRecord]?, _ error: Error?) -> Void
        ) {
        let database = usePublicDatabase ? publicCloudDatabase : privateCloudDatabase
        
        database.perform(query, inZoneWith: zoneID, completionHandler: completionHandler)
    }
    
    /**
     Fetches one record asynchronously, with a low priority, from the specified database, and calls a handler upon completion.
     */
    func getRecord(
        byId recordId: CKRecord.ID,
        usePublicDatabase: Bool = false,
        completionHandler: @escaping (_ record: CKRecord?, _ error: Error?) -> Void
        ) {
        let database = usePublicDatabase ? publicCloudDatabase : privateCloudDatabase
        
        let fetchRecordsOperation = CKFetchRecordsOperation()
        fetchRecordsOperation.database = database
        fetchRecordsOperation.recordIDs = [recordId]
        
        fetchRecordsOperation.fetchRecordsCompletionBlock = { (_ records: [CKRecord.ID: CKRecord]?, _ error: Error?) in
            completionHandler(records?[recordId], error)
        }
        
        fetchRecordsOperation.start()
    }

    /**
     Store one record asynchronously, with a low priority, on the specified database, and calls a handler upon completion.
     */
    func storeRecord(
        _ aCKRecord: CKRecord,
        usePublicDatabase: Bool = false,
        completionHandler: @escaping (_ record: CKRecord?, _ error: Error?) -> Void
        ) {
        let database = usePublicDatabase ? publicCloudDatabase : privateCloudDatabase
        
        let modifyRecordsOperation = CKModifyRecordsOperation()
        modifyRecordsOperation.database = database
        modifyRecordsOperation.recordsToSave = [aCKRecord]
        
        modifyRecordsOperation.perRecordCompletionBlock = { (ckRecord, error) in
            guard error == nil else {
                print(error!)
                return
            }
        }
        modifyRecordsOperation.modifyRecordsCompletionBlock = { (savedRecordList, deletedRecordIDList, error ) in
            completionHandler(savedRecordList?.first, error)
        }
        modifyRecordsOperation.start()
    }

    /**
     Destroy one record asynchronously, with a low priority, on the specified database, and calls a handler upon completion.
     */
    func destroyRecord(
        _ aCKRecord: CKRecord,
        usePublicDatabase: Bool = false,
        completionHandler: @escaping (_ recordId: CKRecord.ID?, _ error: Error?) -> Void
        ) {
        let database = usePublicDatabase ? publicCloudDatabase : privateCloudDatabase
        
        let modifyRecordsOperation = CKModifyRecordsOperation()
        modifyRecordsOperation.database = database
        modifyRecordsOperation.recordIDsToDelete = [aCKRecord.recordID]
        
        modifyRecordsOperation.perRecordCompletionBlock = { (ckRecord, error) in
            guard error == nil else {
                print(error!)
                return
            }
        }
        modifyRecordsOperation.modifyRecordsCompletionBlock = { (savedRecordList, deletedRecordIDList, error ) in
            completionHandler(deletedRecordIDList?.first, error)
        }
        modifyRecordsOperation.start()
    }


    /**
     Modify records asynchronously, with a low priority, on the specified database, and calls a handler upon completion.
     */
    func modifyRecords(
        recordsToSave: [CKRecord],
        recordIDsToDelete: [CKRecord.ID],
        usePublicDatabase: Bool = false,
        perRecordProgressBlock: ((_ record: CKRecord, _ progress: Double) -> Void)?,
        perRecordCompletionBlock: ((_ record: CKRecord, _ error: Error?) -> Void)?,
        completionHandler: ((_ savedRecords: [CKRecord]?, _ deletedRecordIDs: [CKRecord.ID]?, _ error: Error?) -> Void)?
        ) {
        
        let database = usePublicDatabase ? publicCloudDatabase : privateCloudDatabase
        
        let modifyRecordsOperation = CKModifyRecordsOperation()
        modifyRecordsOperation.database = database
        
        modifyRecordsOperation.recordsToSave = recordsToSave
        modifyRecordsOperation.recordIDsToDelete = recordIDsToDelete
        modifyRecordsOperation.perRecordProgressBlock = perRecordProgressBlock
        modifyRecordsOperation.perRecordCompletionBlock = perRecordCompletionBlock
        modifyRecordsOperation.modifyRecordsCompletionBlock = completionHandler
        
        modifyRecordsOperation.start()
    }
}
