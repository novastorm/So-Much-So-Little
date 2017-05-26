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
    
    static func postProject(with data: [AnyHashable: Any], completionHandler: @escaping(_ activity: CKRecord?, _ error: Error?) -> Void) {
        
        let ckActivity = CKRecord(recordType: RecordType.Activity.rawValue)
        ckActivity[Activity.Keys.Name] = data[Activity.Keys.Name] as? CKRecordValue
        
        // TODO: add completion handler code
    }
    
    
    // MARK: - Destroy method
    
    static func deleteProject(_ recordIdString: String, completionHandler: @escaping (_ activity: CKRecord?, _ error: Error?) -> Void) {
        
    }
}
