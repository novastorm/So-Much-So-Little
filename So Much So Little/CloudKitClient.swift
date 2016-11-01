//
//  CloudKitClient.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/17/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CloudKit

class CloudKitClient {
    
    public enum RecordType: String {
        case Activity, Project
    }
    
    static var ubiquityIdentityToken: Any? {
        return FileManager.default.ubiquityIdentityToken
    }

    static var publicDatabase: CKDatabase {
        return CKContainer.default().publicCloudDatabase
    }
    
    static var privateDatabase: CKDatabase {
        return CKContainer.default().privateCloudDatabase
    }
    
    // MARK: - GET INDEX
    // MARK: - GET
    // MARK: - POST
    // MARK: - PUT
    // MARK: - DELETE
}
