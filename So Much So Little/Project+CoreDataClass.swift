//
//  Project+CoreDataClass.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/14/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CloudKit
import CoreData


public class Project: NSManagedObject {
    
    struct Keys {
        static let Active = "active"
        static let Completed = "completed"
        static let CompletedDate = "completedDate"
        static let CKRecordID = "ckRecordID"
        static let DisplayOrder = "displayOrder"
        static let DueDate = "dueDate"
        static let Info = "info"
        static let Name = "name"
        
        static let Activities = "activities"
    }
    
    typealias ActiveType = Bool
    typealias CKRecordIDType = Data
    typealias CompletedType = Bool
    typealias CompletedDateType = Date
    typealias DisplayOrderType = NSNumber
    typealias DueDateType = Date
    typealias InfoType = String
    typealias NameType = String
    
    typealias ActivitiesType = Set<Activity>
    
    static let defaultName = "New Project"
    
    convenience init(context: NSManagedObjectContext, name: String) {
        let className = type(of: self).className
        let entity = NSEntityDescription.entity(forEntityName: className, in: context)!
        
        self.init(entity: entity, insertInto: context)
        
        var name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty {
            name = type(of: self).defaultName
        }
        
        self.name = name
    }
    
    convenience init(context: NSManagedObjectContext) {
        self.init(context: context, name: type(of: self).defaultName)
    }

    convenience init(context: NSManagedObjectContext, data: [AnyHashable:Any]) {
        let name = data[Keys.Name] as? NameType ?? ""
        self.init(context: context, name: name)
        
        active = data[Keys.Active] as? ActiveType ?? false
        ckRecordID = data[Keys.CKRecordID] as? CKRecordIDType
        completed = data[Keys.Completed] as? CompletedType ?? false
        completedDate = data[Keys.CompletedDate] as? CompletedDateType
        displayOrder = data[Keys.DisplayOrder] as? DisplayOrderType ?? 0
        dueDate = data[Keys.DueDate] as? DueDateType
        info = data[Keys.Info] as? InfoType
    }
    
    convenience init(context: NSManagedObjectContext, ckRecord: CKRecord) {
        let data: [AnyHashable: Any] = [
            Keys.Active: ckRecord[Keys.Active] as Any,
            Keys.CKRecordID: ckRecord.encodedCKRecordSystemFields,
            Keys.Completed: ckRecord[Keys.Completed] as Any,
            Keys.CompletedDate: ckRecord[Keys.CompletedDate] as Any,
            Keys.DisplayOrder: ckRecord[Keys.DisplayOrder] as Any,
            Keys.DueDate: ckRecord[Keys.DueDate] as Any,
            Keys.Info: ckRecord[Keys.Info] as Any,
            Keys.Name: ckRecord[Keys.Name] as Any
        ]
        
        self.init(context: context, data: data)
    }
    
    public override func didSave() {
        if isDeleted {
            print("Delete Project [\(self.name)] didSave")
            return
        }
        if managedObjectContext == CoreDataStackManager.mainContext {
            print("Project [\(self.name)] didSave")
            
            // if ckrecordid does not exist create record
            // else fetch record and update
            
            var projectCKRecord: CKRecord
            
            if ckRecordID == nil {
                print("Project: Creating Cloud Kit record")
                projectCKRecord = CKRecord(recordType: CloudKitClient.RecordType.Project.rawValue)
            }
            else {
                print("Project: Update Cloud Kit record")
                projectCKRecord = CKRecord.decodeCKRecordSystemFields(from: ckRecordID!)
            }
            
            projectCKRecord[Keys.Active] = active as NSNumber
            projectCKRecord[Keys.Completed] = completed as NSNumber
            projectCKRecord[Keys.CompletedDate] = completedDate as NSDate?
            projectCKRecord[Keys.DisplayOrder] = displayOrder
            projectCKRecord[Keys.DueDate] = dueDate as NSDate?
            projectCKRecord[Keys.Info] = info as NSString?
            projectCKRecord[Keys.Name] = name as NSString?
            
            CloudKitClient.privateDatabase.save(projectCKRecord) { (ckRecord, error) in
                print("project uploaded to cloudkit")
            }
        }
    }
}
