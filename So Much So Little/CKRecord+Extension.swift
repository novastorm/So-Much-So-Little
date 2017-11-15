//
//  CKRecord+Extension.swift
//  So Much So Little
//
//  Created by Adland Lee on 11/10/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import Foundation
import CloudKit

extension CKRecord {
    
    class func decodeCKRecordSystemFields(from data: Data) -> CKRecord {
        let coder = NSKeyedUnarchiver(forReadingWith: data)
        let record = CKRecord(coder: coder)
        
        coder.finishDecoding()
        
        return record!
    }
    
    var encodedCKRecordSystemFields: Data {
        
        let data = NSMutableData()
        let coder = NSKeyedArchiver(forWritingWith: data)
        
        encodeSystemFields(with: coder)
        
        coder.finishEncoding()
        
        return data as Data
    }
    
}
