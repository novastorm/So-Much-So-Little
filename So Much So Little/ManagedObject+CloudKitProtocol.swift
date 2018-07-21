//
//  ManagedObject+CloudKitProtocol.swift
//  So Much So Little
//
//  Created by Adland Lee on 5/29/17.
//  Copyright © 2017 Adland Lee. All rights reserved.
//

import CloudKit
import CoreData
import Foundation

//@objc // <-- required for Core Data compatability
protocol CloudKitManagedObject {
    
    var cloudKitClient: CloudKitClient { get }
    
    var cloudKitRecord: CKRecord { get set }
    var ckRecordIdName: String? { get set}
    var encodedCKRecord: Data? { get set }

    init(
        insertInto context: NSManagedObjectContext,
        with ckRecord: CKRecord
    )
}
