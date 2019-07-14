//
//  CKRecord+Extension.swift
//  So Much So Little
//
//  Created by Adland Lee on 11/10/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import os
import Foundation
import CloudKit

extension CKRecord {
    
    class func decodeCKRecordSystemFields(from data: Data) -> CKRecord? {
//        let coder = NSKeyedUnarchiver(forReadingWith: data)
//        let copy = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(NSKeyedArchiver.archivedData(withRootObject:view, requiringSecureCoding:false))
        
        var coder: NSKeyedUnarchiver
        do {
            coder = try NSKeyedUnarchiver(forReadingFrom: data)
        }
        catch {
            os_log("Could not read file.")
            return nil
        }

        let record = CKRecord(coder: coder)
        
        coder.finishDecoding()
        
        return record
    }
    
    var encodedCKRecordSystemFields: Data {
        
        let coder = NSKeyedArchiver(requiringSecureCoding: false)
        
        encodeSystemFields(with: coder)
        
        return coder.encodedData
    }
    
}
