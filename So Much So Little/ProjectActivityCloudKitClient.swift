//
//  ProjectActivityDataSource.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/9/18.
//  Copyright © 2018 Adland Lee. All rights reserved.
//

import CloudKit
import UIKit

class ProjectActivityCloudKitClient {
    var cloudKitClient: CloudKitClient!
    var publicCloudDatabase: CKDatabase {
        return cloudKitClient.publicCloudDatabase
    }
    var privateCloudDatabase: CKDatabase {
        return cloudKitClient.privateCloudDatabase
    }
    var projectCloudKitClient: ProjectCloudKitClient!
    var activityCloudKitClient: ActivityCloudKitClient!
    
    init(
        cloudKitClient: CloudKitClient = (UIApplication.shared.delegate as! AppDelegate).cloudKitClient,
        projectCloudKitClient: ProjectCloudKitClient = ProjectCloudKitClient(),
        activityCloudKitClient: ActivityCloudKitClient = ActivityCloudKitClient()
        ) {
        self.cloudKitClient = cloudKitClient
        self.projectCloudKitClient = projectCloudKitClient
        self.activityCloudKitClient = activityCloudKitClient
    }
    
    func importDefaultRecords(
        completionHandler: @escaping (
            _ results: [String: [CKRecord]]?,
            _ error: Error?) -> Void
        ) {
    
        // TODO: Check network connection
        
        guard cloudKitClient.ubiquityIdentityToken != nil else {
            print("Log into iCloud for remote sync")
            return
        }
        
        let group = DispatchGroup()

        var ckProjectList = [CKRecord]()
        var ckActivityList = [CKRecord]()
        
        group.enter()
        projectCloudKitClient.getRecordList(usePublicDatabase: true)
        { (results, error) in
            defer {
                group.leave()
            }
            guard error == nil else {
                print(error!)
                return
            }
            
            for project in results! {
                // FIXME: refactor to save a coredata object
                let newProject = CKRecord(recordType: project.recordType, recordID: project.recordID)
                
                for key in project.allKeys() {
                    newProject[key] = project[key]
                }
                ckProjectList.append(newProject)
            }
        }
        
        group.enter()
        activityCloudKitClient.getRecordList(usePublicDatabase: true) { (results, error) in
            defer {
                group.leave()
            }
            guard error == nil else {
                print(error!)
                return
            }
            
            for activity in results! {
                // FIXME: refactor to save a coredata object
                let newActivity = CKRecord(recordType: activity.recordType, recordID: activity.recordID)
                
                for key in activity.allKeys() {
                    newActivity[key] = activity[key]
                }
                
                ckActivityList.append(newActivity)
            }
        }
        
        group.notify(queue: .main) {
            completionHandler(
                [
                    "ckProjectList": ckProjectList,
                    "ckActivityList": ckActivityList
                ],
                nil
            )
        }
    }
    
    
    func importRecords(completionHandler: @escaping (_ results: [String: [CKRecord]]?, _ error: Error?) -> Void) {
        
        // TODO: Check network connection
        
        guard cloudKitClient.ubiquityIdentityToken != nil else {
            print("Log into iCloud for remote sync")
            return
        }

        let group = DispatchGroup()
        
        var ckProjectList = [CKRecord]()
        var ckActivityList = [CKRecord]()
        
        group.enter()
        projectCloudKitClient.getRecordList() { (results, error) in
            defer {
                group.leave()
            }
            guard error == nil else {
                print(error!)
                return
            }
            
            ckProjectList = results!
        }
        
        group.enter()
        activityCloudKitClient.getRecordList() { (results, error) in
            defer {
                group.leave()
            }
            guard error == nil else {
                print(error!)
                return
            }
            
            ckActivityList = results!
        }
        
        group.notify(queue: .main) {

            completionHandler(
                [
                    "ckProjectList": ckProjectList,
                    "ckActivityList": ckActivityList
                ],
                nil
            )
            
        }
    }

}
