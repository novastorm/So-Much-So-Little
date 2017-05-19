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


public class Project: NSManagedObject {
    
    struct Keys {
        static let Active = "active"
        static let Completed = "completed"
        static let CompletedDate = "completedDate"
        static let EncodedCKRecord = "encodedCKRecord"
        static let DisplayOrder = "displayOrder"
        static let DueDate = "dueDate"
        static let Info = "info"
        static let Name = "name"
        
        static let Activities = "activities"
    }
    
    public typealias ActiveType = Bool
    public typealias EncodedCKRecordType = Data
    public typealias CompletedType = Bool
    public typealias CompletedDateType = Date
    public typealias DisplayOrderType = Int16
    public typealias DueDateType = Date
    public typealias InfoType = String
    public typealias NameType = String
    
    public typealias ActivitiesType = Set<Activity>
    
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
        encodedCKRecord = data[Keys.EncodedCKRecord] as? EncodedCKRecordType
        completed = data[Keys.Completed] as? CompletedType ?? false
        completedDate = data[Keys.CompletedDate] as? CompletedDateType
        displayOrder = data[Keys.DisplayOrder] as? DisplayOrderType ?? 0
        dueDate = data[Keys.DueDate] as? DueDateType
        info = data[Keys.Info] as? InfoType
    }
    
    convenience init(context: NSManagedObjectContext, ckRecord: CKRecord) {
        let data: [AnyHashable: Any] = [
            Keys.Active: ckRecord[Keys.Active] as Any,
            Keys.EncodedCKRecord: ckRecord.encodedCKRecordSystemFields,
            Keys.Completed: ckRecord[Keys.Completed] as Any,
            Keys.CompletedDate: ckRecord[Keys.CompletedDate] as Any,
            Keys.DisplayOrder: ckRecord[Keys.DisplayOrder] as Any,
            Keys.DueDate: ckRecord[Keys.DueDate] as Any,
            Keys.Info: ckRecord[Keys.Info] as Any,
            Keys.Name: ckRecord[Keys.Name] as Any
        ]
        
        self.init(context: context, data: data)
    }
    
    override public func didSave() {
        if isDeleted {
            print("Delete Project [\(self.name)] didSave")
            return
        }
        if managedObjectContext == CoreDataStackManager.mainContext {
            print("Project [\(self.name)] didSave")
            
            // if ckrecordid does not exist create record
            // else fetch record and update
            
            var projectCKRecord: CKRecord
            
            if encodedCKRecord == nil {
                print("Project: Creating Cloud Kit record")
                projectCKRecord = CKRecord(recordType: CloudKitClient.RecordType.Project.rawValue)
            }
            else {
                print("Project: Update Cloud Kit record")
                projectCKRecord = CKRecord.decodeCKRecordSystemFields(from: encodedCKRecord! as Data)
            }
            
            projectCKRecord[Keys.Active] = active as NSNumber
            projectCKRecord[Keys.Completed] = completed as NSNumber
            projectCKRecord[Keys.CompletedDate] = completedDate as NSDate?
            projectCKRecord[Keys.DisplayOrder] = displayOrder as NSNumber
            projectCKRecord[Keys.DueDate] = dueDate as NSDate?
            projectCKRecord[Keys.Info] = info as NSString?
            projectCKRecord[Keys.Name] = name as NSString
            
            let activityRefList = activities.map({ (activity) -> CKReference in
                let ckRecord = CKRecord.decodeCKRecordSystemFields(from: activity.encodedCKRecord! as Data)
                return CKReference(record: ckRecord, action: CKReferenceAction.none)
            })
            
            projectCKRecord[Keys.Activities] = activityRefList as CKRecordValue?
            
            CloudKitClient.privateDatabase.save(projectCKRecord) { (ckRecord, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                print("Project: uploaded to cloudkit")
            }
        }
    }
}
