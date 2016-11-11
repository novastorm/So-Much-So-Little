//
//  Activity+CoreDataClass.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/14/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CloudKit
import CoreData


public class Activity: NSManagedObject {
    
    @objc // <- required for Core Data type compatibility
    public enum Kind: Int32, CustomStringConvertible {
        case flexible
        case deferred
        case reference
        case scheduled
        
        static func fromString(_ string: String) -> Kind? {
            switch string {
            case "Flexible":
                return .flexible
            case "Deferred":
                return .deferred
            case "Reference":
                return .reference
            case "Scheduled":
                return .scheduled
            default:
                return nil
            }
        }
        
        public var description: String {
            switch self {
            case .flexible: return "Flexible"
            case .deferred: return "Deferred"
            case .reference: return "Reference"
            case .scheduled: return "Scheduled"
            }
        }
    }
    
    struct Keys {
        static let EncodedCKRecord = "encodedCKRecord"
        static let Completed = "completed"
        static let CompletedDate = "completedDate"
        static let DeferredTo = "deferredTo"
        static let DeferredToResponseDueDate = "deferredToResponseDueDate"
        static let DisplayOrder = "displayOrder"
        static let DueDate = "dueDate"
        static let EstimatedTimeboxes = "estimatedTimeboxes"
        static let Info = "info"
        static let Kind = "kind"
        static let ScheduledEnd = "scheduledEnd"
        static let ScheduledStart = "scheduledStart"
        static let Name = "name"
        static let Today = "today"
        static let TodayDisplayOrder = "todayDisplayOrder"
        
        static let Project = "project"
        static let Timeboxes = "timeboxes"
    }
    
    typealias EncodedCKRecordType = Data
    typealias CompletedType = Bool
    typealias CompletedDateType = Date
    typealias DeferredToType = String
    typealias DeferredToResponseDueDateType = Date
    typealias DisplayOrderType = NSNumber
    typealias DueDateType = Date
    typealias EstimatedTimeboxesType = NSNumber
    typealias InfoType = String
    //    typealias Kind = Kind
    typealias ScheduledEndType = Date
    typealias ScheduledStartType = Date
    typealias NameType = String
    typealias TodayType = Bool
    typealias TodayDisplayOrderType = NSNumber
    
    typealias ProjectType = Project
    typealias TimeBoxesType = Set<Timebox>
    
    static let defaultName = "New Activity"
    
    /**
     Create an instance with given `name` or defaultName if `name` contains only whitespace.
     
     - parameters:
        - context:
            The context into which the new instance is inserted.
        - name:
            The name property of the instance. Defaults to defaultName if containing only whitespace.
     */
    convenience init(context: NSManagedObjectContext, name: String) {

        let className = type(of: self).className
        let entity = NSEntityDescription.entity(forEntityName: className, in: context)!
        
        self.init(entity: entity, insertInto: context)
        
        var name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty {
            name = type(of: self).defaultName
        }
        
        self.name = name
        kind = .flexible
    }

    /**
     Create an default instance.
     
     - parameters:
         - context:
            The context into which the new instance is inserted.
     */
    convenience init(context: NSManagedObjectContext) {
        self.init(context: context, name: type(of: self).defaultName)
    }
    
    /**
     Create an instance from the given `data`.
     
     - parameters:
        - context:
            The context into which the new instance is inserted.
        - data:
            A dictionary of property keys and values.
     */
    convenience init(context: NSManagedObjectContext, data: [AnyHashable:Any]) {
        let name = data[Keys.Name] as? NameType ?? ""
        self.init(context: context, name: name)
        
        encodedCKRecord = data[Keys.EncodedCKRecord] as? EncodedCKRecordType
        completed = data[Keys.Completed] as? CompletedType ?? false
        completedDate = data[Keys.CompletedDate] as? CompletedDateType
        deferredTo = data[Keys.DeferredTo] as? DeferredToType
        deferredToResponseDueDate = data[Keys.DeferredToResponseDueDate] as? DeferredToResponseDueDateType
        displayOrder = data[Keys.DisplayOrder] as? DisplayOrderType ?? 0
        dueDate = data[Keys.DueDate] as? DueDateType
        estimatedTimeboxes = data[Keys.EstimatedTimeboxes] as? EstimatedTimeboxesType ?? 0
        info = data[Keys.Info] as? InfoType
        kind = data[Keys.Kind] as? Kind ?? .flexible
        scheduledEnd = data[Keys.ScheduledEnd] as? ScheduledEndType
        scheduledStart = data[Keys.ScheduledStart] as? ScheduledStartType
        today = data[Keys.Today] as? TodayType ?? false
        todayDisplayOrder = data[Keys.TodayDisplayOrder] as? TodayDisplayOrderType ?? 0
        
    }
    
    /**
     Create an instance from the given `ckRecord`.
     
     - parameters:
         - context:
             The context into which the new instance is inserted.
         - ckRecord:
             A Cloud Kit Record.
     */
    
    convenience init(context: NSManagedObjectContext, ckRecord: CKRecord) {
        let data: [AnyHashable: Any] = [
            Keys.EncodedCKRecord: ckRecord.encodedCKRecordSystemFields,
            Keys.Completed: ckRecord[Keys.Completed] as Any,
            Keys.CompletedDate: ckRecord[Keys.CompletedDate] as Any,
            Keys.DeferredTo: ckRecord[Keys.DeferredTo] as Any,
            Keys.DeferredToResponseDueDate: ckRecord[Keys.DeferredToResponseDueDate] as Any,
            Keys.DisplayOrder: ckRecord[Keys.DisplayOrder] as Any,
            Keys.DueDate: ckRecord[Keys.DueDate] as Any,
            Keys.EstimatedTimeboxes: ckRecord[Keys.EstimatedTimeboxes] as Any,
            Keys.Info: ckRecord[Keys.Info] as Any,
            Keys.Kind: ckRecord[Keys.Kind] as Any,
            Keys.Name: ckRecord[Keys.Name] as Any,
            Keys.ScheduledEnd: ckRecord[Keys.ScheduledEnd] as Any,
            Keys.ScheduledStart: ckRecord[Keys.ScheduledStart] as Any,
            Keys.Today: ckRecord[Keys.Today] as Any,
            Keys.TodayDisplayOrder: ckRecord[Keys.TodayDisplayOrder] as Any
        ]
        
        self.init(context: context, data: data)
    }

    var actualTimeboxes: Int {
        return timeboxes.count 
    }
    
    /**
     Save CloudKit object
     */
    
    public override func didSave() {
        if isDeleted {
            print("Delete Activity [\(self.name)] didSave")
            return
        }
        if managedObjectContext == CoreDataStackManager.mainContext {
            
            var activityCKRecord: CKRecord
            
            if encodedCKRecord == nil {
                print("Activity: Create Cloud Kit record")
                activityCKRecord = CKRecord(recordType: CloudKitClient.RecordType.Activity.rawValue)
            }
            else {
                print("Activity: Update Cloud Kit record")
                activityCKRecord = CKRecord.decodeCKRecordSystemFields(from: encodedCKRecord!)
            }
            
            activityCKRecord[Keys.Completed] = completed as NSNumber
            activityCKRecord[Keys.CompletedDate] = completedDate as NSDate?
            activityCKRecord[Keys.DeferredTo] = deferredTo as NSString?
            activityCKRecord[Keys.DeferredToResponseDueDate] = deferredToResponseDueDate as NSDate?
            activityCKRecord[Keys.DisplayOrder] = displayOrder as NSNumber
            activityCKRecord[Keys.DueDate] = dueDate as NSDate?
            activityCKRecord[Keys.EstimatedTimeboxes] = estimatedTimeboxes as NSNumber
            activityCKRecord[Keys.Info] = info as NSString?
            activityCKRecord[Keys.Kind] = kind.rawValue as NSNumber
            activityCKRecord[Keys.Name] = name as NSString?
            activityCKRecord[Keys.ScheduledEnd] = scheduledEnd as NSDate?
            activityCKRecord[Keys.ScheduledStart] = scheduledStart as NSDate?
            activityCKRecord[Keys.Today] = today as NSNumber
            activityCKRecord[Keys.TodayDisplayOrder] = todayDisplayOrder as NSNumber
            
            if let project = project {
                let ckRecord = CKRecord.decodeCKRecordSystemFields(from: project.encodedCKRecord!)
                activityCKRecord[Keys.Project] = CKReference(record: ckRecord, action: .none)
            }
            
            
            CloudKitClient.privateDatabase.save(activityCKRecord) { (ckRecord, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                print("Activity: Uploaded to cloudkit")
            }
        }
    }
}
