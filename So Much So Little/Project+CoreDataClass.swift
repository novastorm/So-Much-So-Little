//
//  Project+Extensions.swift
//  So Much So Little
//
//  Created by Adland Lee on 5/17/17.
//  Copyright © 2017 Adland Lee. All rights reserved.
//

import CloudKit
import CoreData
import UIKit

struct ProjectOptions {
    var active: Project.ActiveType
    var completed: Project.CompletedType
    var completedDate: Project.CompletedDateType?
    var displayOrder: Project.DisplayOrderType
    var dueDate: Project.DueDateType?
    var info: Project.InfoType?
    var name: Project.NameType
    
    init(
        active: Project.ActiveType = false,
        completed: Project.CompletedType = false,
        completedDate: Project.CompletedDateType? = nil,
        displayOrder: Project.DisplayOrderType = 0,
        dueDate: Project.DueDateType? = nil,
        info: Project.InfoType? = nil,
        name: Project.NameType = Project.defaultName
        ) {
        self.active = active
        self.completed = completed
        self.completedDate = completedDate
        self.displayOrder = displayOrder
        self.dueDate = dueDate
        self.info = info
        self.name = name
    }
}

final public class Project: NSManagedObject, CloudKitManagedObject {
    
    struct Keys {
        static let EncodedCKRecord = "encodedCKRecord"
        static let CKRecordIdName = "ckRecordId"

        static let Active = "active"
        static let Completed = "completed"
        static let CompletedDate = "completedDate"
        static let DisplayOrder = "displayOrder"
        static let DueDate = "dueDate"
        static let Info = "info"
        static let IsSynced = "isSynced"
        static let Name = "name"
        
        static let Activities = "activities"
    }
    
    public typealias CKRecordIdNameType = String
    public typealias EncodedCKRecordType = Data

    public typealias ActiveType = Bool
    public typealias CompletedType = Bool
    public typealias CompletedDateType = Date
    public typealias DisplayOrderType = Int16
    public typealias DueDateType = Date
    public typealias InfoType = String
    public typealias IsSynced = Bool
    public typealias NameType = String
    
    public typealias ActivitiesType = Set<Activity>
    
    static let defaultName = "New Project"
    
    var cloudKitRecord: CKRecord {
        get {
            let ckRecord = CKRecord.decodeCKRecordSystemFields(from: encodedCKRecord! as Data)

            ckRecord[Keys.Active] = active as NSNumber
            ckRecord[Keys.Completed] = completed as NSNumber
            ckRecord[Keys.CompletedDate] = completedDate as NSDate?
            ckRecord[Keys.DisplayOrder] = displayOrder as NSNumber
            ckRecord[Keys.DueDate] = dueDate as NSDate?
            ckRecord[Keys.Info] = info as NSString?
            ckRecord[Keys.Name] = name as NSString

//            for key in ckRecord.allKeys() {
//                ckRecord.setValue(value(forKey: key), forKey: key)
//            }
            
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
     Create an instance from given ProjectOptions
     
     - parameters:
         - context:
         The context into which the new instance is inserted.
         - options:
         The ProjectOptions record
     */
    convenience init(insertInto context: NSManagedObjectContext, with options: ProjectOptions = ProjectOptions()) {
        
        let typename = type(of: self).typeName
        let entity = NSEntityDescription.entity(forEntityName: typename, in: context)!
        
        self.init(entity: entity, insertInto: context)
        
        let ckRecord = CKRecord(recordType: CloudKitClient.RecordType.Project.rawValue)
        
        encodedCKRecord = ckRecord.encodedCKRecordSystemFields
        ckRecordIdName = ckRecord.recordID.recordName

        active = options.active
        completed = options.completed
        completedDate = options.completedDate
        displayOrder = options.displayOrder
        dueDate = options.dueDate
        info = options.info
        name = options.name
        
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty {
            name = type(of: self).defaultName
        }
    }
    
    /**
     Create an instance from the given `ckRecord`.
     
     - parameters:
        - context:
            The context into which the new instance is inserted.
        - ckRecord:
            A Cloud Kit Record.
     */
    convenience init(insertInto context: NSManagedObjectContext, with ckRecord: CKRecord) {
        let name = ckRecord[Keys.Name] as! String
        self.init(insertInto: context, with: ProjectOptions(name: name))
        cloudKitRecord = ckRecord
    }
    
    public override func didSave() {

        if managedObjectContext == CoreDataStackManager.shared.mainContext {
            
            if isDeleted {
                showNetworkActivityIndicator()
                CloudKitClient.destroyProject(self.cloudKitRecord) { (ckRecordID, error) in
                    hideNetworkActivityIndicator()
                    guard error == nil else {
                        print("Error deleting \(type(of:self))", error!)
                        return
                    }
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
            
            showNetworkActivityIndicator()
            CloudKitClient.getProject(ckRecordIdName!) { (remoteCKRecord, error) in
                hideNetworkActivityIndicator()
                guard error == nil else {
                    guard ConnectionMonitor.shared.isConnectedToNetwork() else {
                        self.managedObjectContext?.perform {
                            self.setPrimitiveValue(NSNumber.init(value: false), forKey: Keys.IsSynced)
                        }
                        return
                    }
                    
                    showNetworkActivityIndicator()
                    CloudKitClient.storeProject(localCKRecord) { (ckRecord, error) in
                        hideNetworkActivityIndicator()
                        guard error == nil else {
                            print("\(type(of:self)) storeReord", error!)
                            return
                        }

                        self.managedObjectContext?.perform {
                            self.setPrimitiveValue(ckRecord!.encodedCKRecordSystemFields, forKey: Keys.EncodedCKRecord)
                            self.setPrimitiveValue(NSNumber.init(value: true), forKey: Keys.IsSynced)
                        }
                    }
                    
                    return
                }
                
                let remoteCKRecord = remoteCKRecord!
                
                for key in localCKRecord.allKeys() {
                    remoteCKRecord.setObject(localCKRecord.object(forKey: key), forKey: key)
                }
                
                showNetworkActivityIndicator()
                CloudKitClient.storeProject(remoteCKRecord) { (ckRecord, error) in
                    hideNetworkActivityIndicator()
                    guard error == nil else {
                        print("\(type(of:self)) storeReord", error!)
                        return
                    }
                    
                    self.managedObjectContext?.perform {
                        self.setPrimitiveValue(ckRecord!.encodedCKRecordSystemFields, forKey: Keys.EncodedCKRecord)
                    }
                }
            }
        }
    }
}
