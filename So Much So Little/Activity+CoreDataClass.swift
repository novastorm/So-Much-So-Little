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
    public enum Kind: Int16, CustomStringConvertible {

        private enum Name: String {
            case Flexible, Deferred, Reference, Scheduled
        }
        
        case flexible
        case deferred
        case reference
        case scheduled
        
        static func fromString(_ string: String) -> Kind? {
            switch string {
            case Name.Flexible.rawValue:
                return .flexible
            case Name.Deferred.rawValue:
                return .deferred
            case Name.Reference.rawValue:
                return .reference
            case Name.Scheduled.rawValue:
                return .scheduled
            default:
                return nil
            }
        }
        
        public var description: String {
            switch self {
            case .flexible: return Name.Flexible.rawValue
            case .deferred: return Name.Deferred.rawValue
            case .reference: return Name.Reference.rawValue
            case .scheduled: return Name.Scheduled.rawValue
            }
        }
    }
    
    struct Keys {
        static let CKRecordIdName = "ckRecordIdName"
        static let Completed = "completed"
        static let CompletedDate = "completedDate"
        static let DeferredTo = "deferredTo"
        static let DeferredToResponseDueDate = "deferredToResponseDueDate"
        static let DisplayOrder = "displayOrder"
        static let DueDate = "dueDate"
        static let EncodedCKRecord = "encodedCKRecord"
        static let EstimatedTimeboxes = "estimatedTimeboxes"
        static let Info = "info"
        static let IsSynced = "isSynced"
        static let Kind = "kind"
        static let ScheduledEnd = "scheduledEnd"
        static let ScheduledStart = "scheduledStart"
        static let Name = "name"
        static let Today = "today"
        static let TodayDisplayOrder = "todayDisplayOrder"
        
        static let Project = "project"
        static let Timeboxes = "timeboxes"
    }
    
    
    public typealias CKRecordIdNameType = String
    public typealias CompletedType = Bool
    public typealias CompletedDateType = Date
    public typealias DeferredToType = String
    public typealias DeferredToResponseDueDateType = Date
    public typealias DisplayOrderType = Int16
    public typealias DueDateType = Date
    public typealias EncodedCKRecordType = Data
    public typealias EstimatedTimeboxesType = Int16
    public typealias InfoType = String
    public typealias IsSyncedType = Bool
    public typealias ScheduledEndType = Date
    public typealias ScheduledStartType = Date
    public typealias NameType = String
    public typealias TodayType = Bool
    public typealias TodayDisplayOrderType = Int16
    
    public typealias ProjectType = Project
    public typealias TimeBoxesType = Set<Timebox>
    
    static let defaultName = "New Activity"
    
    
    var cloudKitRecord: CKRecord {
        get {
            
            var ckRecord: CKRecord
            
            if encodedCKRecord == nil {
                print("Activity: Create Cloud Kit record")
                ckRecord = CKRecord(recordType: CloudKitClient.RecordType.Activity.rawValue)
                setPrimitiveValue(ckRecord.encodedCKRecordSystemFields, forKey: Keys.EncodedCKRecord)
                setPrimitiveValue(ckRecord.recordID.recordName, forKey: Keys.CKRecordIdName)
            }
            else {
                print("Activity: Update Cloud Kit record")
                ckRecord = CKRecord.decodeCKRecordSystemFields(from: encodedCKRecord! as Data)
            }
            
            ckRecord[Keys.Completed] = completed as NSNumber
            ckRecord[Keys.CompletedDate] = completedDate as NSDate?
            ckRecord[Keys.DeferredTo] = deferredTo as NSString?
            ckRecord[Keys.DeferredToResponseDueDate] = deferredToResponseDueDate as NSDate?
            ckRecord[Keys.DisplayOrder] = displayOrder as NSNumber
            ckRecord[Keys.DueDate] = dueDate as NSDate?
            ckRecord[Keys.EstimatedTimeboxes] = estimatedTimeboxes as NSNumber
            ckRecord[Keys.Info] = info as NSString?
            ckRecord[Keys.Kind] = kind.rawValue as NSNumber
            ckRecord[Keys.Name] = name as NSString
            ckRecord[Keys.ScheduledEnd] = scheduledEnd as NSDate?
            ckRecord[Keys.ScheduledStart] = scheduledStart as NSDate?
            ckRecord[Keys.Today] = today as NSNumber
            ckRecord[Keys.TodayDisplayOrder] = todayDisplayOrder as NSNumber
            
            if let project = project {
                let ckRecordRef = CKRecord.decodeCKRecordSystemFields(from: project.encodedCKRecord! as Data)
                ckRecord[Keys.Project] = CKReference(record: ckRecordRef, action: .none)
            }
            
            return ckRecord
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

        let className = type(of: self).className
        let entity = NSEntityDescription.entity(forEntityName: className, in: context)!
        
        self.init(entity: entity, insertInto: context)
        
        var name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty {
            name = type(of: self).defaultName
        }
        
        self.name = name
        self.kind = .flexible
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
        
        ckRecordIdName = data[Keys.CKRecordIdName] as? CKRecordIdNameType
        completed = data[Keys.Completed] as? CompletedType ?? false
        completedDate = data[Keys.CompletedDate] as? CompletedDateType
        deferredTo = data[Keys.DeferredTo] as? DeferredToType
        deferredToResponseDueDate = data[Keys.DeferredToResponseDueDate] as? DeferredToResponseDueDateType
        displayOrder = data[Keys.DisplayOrder] as? DisplayOrderType ?? 0
        dueDate = data[Keys.DueDate] as? DueDateType
        encodedCKRecord = data[Keys.EncodedCKRecord] as? EncodedCKRecordType
        estimatedTimeboxes = data[Keys.EstimatedTimeboxes] as? EstimatedTimeboxesType ?? 0
        info = data[Keys.Info] as? InfoType
        isSynced = data[Keys.IsSynced] as? IsSyncedType ?? false
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
            
            Keys.CKRecordIdName: ckRecord.recordID.recordName,
            Keys.Completed: ckRecord[Keys.Completed] as Any,
            Keys.CompletedDate: ckRecord[Keys.CompletedDate] as Any,
            Keys.DeferredTo: ckRecord[Keys.DeferredTo] as Any,
            Keys.DeferredToResponseDueDate: ckRecord[Keys.DeferredToResponseDueDate] as Any,
            Keys.DisplayOrder: ckRecord[Keys.DisplayOrder] as Any,
            Keys.DueDate: ckRecord[Keys.DueDate] as Any,
            Keys.EncodedCKRecord: ckRecord.encodedCKRecordSystemFields,
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
    
    override public func didSave() {
        
        if isDeleted {
            print("Delete Activity [\(self.name)] didSave")
            return
        }
        
        if managedObjectContext == CoreDataStackManager.mainContext {
            print("Activity [\(self.name)] didSave")
            
            let activityCKRecord: CKRecord = self.cloudKitRecord
            
            CloudKitClient.storeRecord(activityCKRecord) { (ckRecord, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                
                self.managedObjectContext?.perform {
                    self.setPrimitiveValue(ckRecord!.encodedCKRecordSystemFields, forKey: Keys.EncodedCKRecord)
                }
                
            }
        }
    }    
}
