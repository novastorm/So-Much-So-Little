//
//  Project+Extensions.swift
//  So Much So Little
//
//  Created by Adland Lee on 5/17/17.
//  Copyright © 2017 Adland Lee. All rights reserved.
//

import CloudKit
import CoreData
import Foundation


final public class Project: NSManagedObject, CloudKitManagedObject {
    
    struct Keys {
        static let Active = "active"
        static let CKRecordIdName = "ckRecordId"
        static let Completed = "completed"
        static let CompletedDate = "completedDate"
        static let EncodedCKRecord = "encodedCKRecord"
        static let DisplayOrder = "displayOrder"
        static let DueDate = "dueDate"
        static let Info = "info"
        static let IsSynced = "isSynced"
        static let Name = "name"
        
        static let Activities = "activities"
    }
    
    
    public typealias ActiveType = Bool
    public typealias CKRecordIdNameType = String
    public typealias CompletedType = Bool
    public typealias CompletedDateType = Date
    public typealias DisplayOrderType = Int16
    public typealias DueDateType = Date
    public typealias EncodedCKRecordType = Data
    public typealias InfoType = String
    public typealias NameType = String
    
    public typealias ActivitiesType = Set<Activity>
    
    static let defaultName = "New Project"
    
    var cloudKitRecord: CKRecord {
        get {
            // if ckrecordid does not exist create record
            // else fetch record and update
            
    //        var ckRecord: CKRecord
    //        
    //        if encodedCKRecord == nil {
    //            print("Project: Creating Cloud Kit record")
    //            ckRecord = CKRecord(recordType: CloudKitClient.RecordType.Project.rawValue)
    //            setPrimitiveValue(ckRecord.encodedCKRecordSystemFields, forKey: Keys.EncodedCKRecord)
    //            setPrimitiveValue(ckRecord.recordID.recordName, forKey: Keys.CKRecordIdName)
    //        }
    //        else {
    //            print("Project: Update Cloud Kit record")
    //            ckRecord = CKRecord.decodeCKRecordSystemFields(from: encodedCKRecord! as Data)
    //        }
            let ckRecord = CKRecord.decodeCKRecordSystemFields(from: encodedCKRecord! as Data)
            
            ckRecord[Keys.Active] = active as NSNumber
            ckRecord[Keys.Completed] = completed as NSNumber
            ckRecord[Keys.CompletedDate] = completedDate as NSDate?
            ckRecord[Keys.DisplayOrder] = displayOrder as NSNumber
            ckRecord[Keys.DueDate] = dueDate as NSDate?
            ckRecord[Keys.Info] = info as NSString?
            ckRecord[Keys.Name] = name as NSString
            
            let activityRefList: [CKReference] = activities.map({ (activity) -> CKReference in
                let ckRecordRef = CKRecord.decodeCKRecordSystemFields(from: activity.encodedCKRecord! as Data)
                return CKReference(record: ckRecordRef, action: .none)
            })
            
            ckRecord[Keys.Activities] = activityRefList as NSArray
            
            return ckRecord
        }
        set {
            encodedCKRecord = newValue.encodedCKRecordSystemFields
            ckRecordIdName = newValue.recordID.recordName
            
            active = newValue[Keys.Active] as? ActiveType ?? false
            completed = newValue[Keys.Completed] as? CompletedType ?? false
            completedDate = newValue[Keys.CompletedDate] as? CompletedDateType
            displayOrder = newValue[Keys.DisplayOrder] as? DisplayOrderType ?? 0
            dueDate = newValue[Keys.DueDate] as? DueDateType
            info = newValue[Keys.Info] as? InfoType
            name = newValue[Keys.Name] as? NameType ?? Project.defaultName
        }
    }
    
    
    /**
     Create an instance with given `name` or defaultName if `name` contains only whitespace.
     
     - parameters:
         - context:
         The context into which the new instance is inserted.
         - name:
         The name property of the instance. Defaults to defaultName if containing only whitespace.
     */
    convenience init(context: NSManagedObjectContext, name: String) {
        
        let className = type(of: self).typeName
        let entity = NSEntityDescription.entity(forEntityName: className, in: context)!
        
        self.init(entity: entity, insertInto: context)
        
        var name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty {
            name = type(of: self).defaultName
        }
        
        self.name = name
        
        let ckRecord = CKRecord(recordType: CloudKitClient.RecordType.Project.rawValue)
        
        self.encodedCKRecord = ckRecord.encodedCKRecordSystemFields
        self.ckRecordIdName = ckRecord.recordID.recordName
    }
    
    convenience init(context: NSManagedObjectContext) {
        self.init(context: context, name: type(of: self).defaultName)
    }
    
    convenience init(context: NSManagedObjectContext, data: [AnyHashable:Any]) {
        let name = data[Keys.Name] as? NameType ?? ""
        self.init(context: context, name: name)
        
        encodedCKRecord = data[Keys.EncodedCKRecord] as? EncodedCKRecordType
        ckRecordIdName = data[Keys.CKRecordIdName] as? CKRecordIdNameType

        active = data[Keys.Active] as? ActiveType ?? false
        completed = data[Keys.Completed] as? CompletedType ?? false
        completedDate = data[Keys.CompletedDate] as? CompletedDateType
        displayOrder = data[Keys.DisplayOrder] as? DisplayOrderType ?? 0
        dueDate = data[Keys.DueDate] as? DueDateType
        info = data[Keys.Info] as? InfoType
    }
    
    convenience init(insertInto context: NSManagedObjectContext, with ckRecord: CKRecord) {
//        let data: [AnyHashable: Any] = [
//            Keys.Active: ckRecord[Keys.Active] as Any,
//            Keys.CKRecordIdName: ckRecord.recordID.recordName,
//            Keys.Completed: ckRecord[Keys.Completed] as Any,
//            Keys.CompletedDate: ckRecord[Keys.CompletedDate] as Any,
//            Keys.DisplayOrder: ckRecord[Keys.DisplayOrder] as Any,
//            Keys.DueDate: ckRecord[Keys.DueDate] as Any,
//            Keys.EncodedCKRecord: ckRecord.encodedCKRecordSystemFields,
//            Keys.Info: ckRecord[Keys.Info] as Any,
//            Keys.Name: ckRecord[Keys.Name] as Any
//        ]

        let name = ckRecord[Keys.Name] as! String
        self.init(context: context, name: name)
        cloudKitRecord = ckRecord
    }
    
    public override func didSave() {

        if managedObjectContext == CoreDataStackManager.shared.mainContext {
//            print("\(type(of:self)) [\(self.name)] \(#function)")
            
            if isDeleted {
                print("Delete \(type(of:self)) [\(self.name)] \(#function)")
                CloudKitClient.destroyProject(self.cloudKitRecord) { (ckRecordID, error) in
                    guard error == nil else {
                        print("Error deleting \(type(of:self))", error!)
                        return
                    }
                    print("Delete \(type(of: self)) \(String(describing: ckRecordID))")
                }
                return
            }
            
            let localCKRecord: CKRecord = self.cloudKitRecord
            do {
                try managedObjectContext?.obtainPermanentIDs(for: [self])
            }
            catch {
                print(error)
            }
            
            CloudKitClient.getProject(ckRecordIdName!) { (remoteCKRecord, error) in
                guard error == nil else {
                    print("Error retrieving \(type(of:self))", error!)
                    
                    CloudKitClient.storeProject(localCKRecord) { (ckRecord, error) in
                        guard error == nil else {
                            print("\(type(of:self)) storeReord", error!)
                            return
                        }

                        self.managedObjectContext?.perform {
                            self.setPrimitiveValue(ckRecord!.encodedCKRecordSystemFields, forKey: Keys.EncodedCKRecord)
                        }
                    }
                    
                    return
                }
                
                let remoteCKRecord = remoteCKRecord!
                
                for key in remoteCKRecord.allKeys() {
                    remoteCKRecord.setObject(localCKRecord.object(forKey: key), forKey: key)
                }
                
//                print("\(type(of:self)) remoteCKRecord ", remoteCKRecord)
                
                CloudKitClient.storeProject(remoteCKRecord) { (ckRecord, error) in
                    guard error == nil else {
                        print("\(type(of:self)) storeReord", error!)
                        return
                    }
                    
//                    print("ckRecord \(String(describing: ckRecord?.recordChangeTag))")
                    
                    self.managedObjectContext?.perform {
                        self.setPrimitiveValue(ckRecord!.encodedCKRecordSystemFields, forKey: Keys.EncodedCKRecord)
                    }
                }
            }
        }
    }
}
