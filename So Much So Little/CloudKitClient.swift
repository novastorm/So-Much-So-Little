//
//  CloudKitClient.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/17/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CloudKit
import UIKit

class CloudKitClient: NSObject {
    
//    var coreDataStack: CoreDataStack!
    
    public enum RecordType: String {
        case Activity, Project
    }
    
    var ubiquityIdentityToken: Any? {
        return FileManager.default.ubiquityIdentityToken
    }

    var publicCloudDatabase: CKDatabase {
        return CKContainer.default().publicCloudDatabase
    }
    
    var privateCloudDatabase: CKDatabase {
        return CKContainer.default().privateCloudDatabase
    }
    
    // MARK: - GET INDEX
    // MARK: - GET
    // MARK: - POST
    // MARK: - PUT
    // MARK: - DELETE
}
