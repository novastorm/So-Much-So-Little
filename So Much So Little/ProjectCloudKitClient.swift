//
//  ProjectCloudKitClient.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/8/18.
//  Copyright © 2018 Adland Lee. All rights reserved.
//

import CloudKit
import UIKit

class ProjectCloudKitClient {
    
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
    
    func getRecordList(
        usePublicDatabase: Bool = false,
        completionHandler: @escaping (_ projectList: [CKRecord]?, _ error: Error?) -> Void
        ) {
        let database = usePublicDatabase ? publicCloudDatabase : privateCloudDatabase

        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Project.typeName, predicate: predicate)
        
        database.perform(query, inZoneWith: nil) { (results, error) in
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            completionHandler(results, nil)
        }
    }
    
    // MARK: - Show method
    
    func getRecord(_ recordIdString: String, usePublicDatabase: Bool = false, completionHandler: @escaping (_ activity: CKRecord?, _ error: Error?) -> Void) {
        let database = usePublicDatabase ? publicCloudDatabase : privateCloudDatabase

        let recordId = CKRecord.ID(recordName: recordIdString)
        
        database.fetch(withRecordID: recordId) { (record, error) in
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            completionHandler(record, nil)
        }
    }
    
    
    // MARK: - Store and update method
    
    func store(
        _ project: CKRecord,
        usePublicDatabase: Bool = false,
        completionHandler: @escaping(_ project: CKRecord?, _ error: Error?) -> Void
        ) {
        let database = usePublicDatabase ? publicCloudDatabase : privateCloudDatabase

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
    
    
    func destroy(
        _ project: CKRecord,
        usePublicDatabase: Bool = false,
        completionHandler: @escaping(_ project: CKRecord.ID?, _ error: Error?) -> Void
        ) {
        let database = usePublicDatabase ? publicCloudDatabase : privateCloudDatabase

        let modifyRecordsOperation = CKModifyRecordsOperation()
        modifyRecordsOperation.database = database
        modifyRecordsOperation.recordIDsToDelete = [project.recordID]
        
        modifyRecordsOperation.perRecordCompletionBlock = { (ckRecord, error) in
            guard error == nil else {
                print(error!)
                return
            }
        }
        modifyRecordsOperation.modifyRecordsCompletionBlock = { (savedRecordList, deletedRecordIDList, error ) in
            completionHandler(deletedRecordIDList?.first!, error)
        }
        modifyRecordsOperation.start()
    }
}
