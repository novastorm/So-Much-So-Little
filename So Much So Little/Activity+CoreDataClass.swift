//
//  Activity+CoreDataClass.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/14/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CloudKit
import CoreData


final public class Activity: NSManagedObject, CloudKitManagedObject {
    
    @objc // <- required for Core Data type compatibility
    public enum Kind: Int16, CustomStringConvertible {

        private enum Name: String {
            case flexible
            case deferred
            case reference
            case scheduled
        }
        
        case flexible
        case deferred
        case reference
        case scheduled
        
        static func fromString(_ string: String) -> Kind? {
            switch string {
            case Name.flexible.rawValue:
                return .flexible
            case Name.deferred.rawValue:
                return .deferred
            case Name.reference.rawValue:
                return .reference
            case Name.scheduled.rawValue:
                return .scheduled
            default:
                return nil
            }
        }
        
        public var description: String {
            switch self {
            case .flexible: return Name.flexible.rawValue
            case .deferred: return Name.deferred.rawValue
            case .reference: return Name.reference.rawValue
            case .scheduled: return Name.scheduled.rawValue
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
            
//            var ckRecord: CKRecord
//            
//            if encodedCKRecord == nil {
//                print("Activity: Create Cloud Kit record")
//                ckRecord = CKRecord(recordType: CloudKitClient.RecordType.Activity.rawValue)
//                setPrimitiveValue(ckRecord.encodedCKRecordSystemFields, forKey: Keys.EncodedCKRecord)
//                setPrimitiveValue(ckRecord.recordID.recordName, forKey: Keys.CKRecordIdName)
//            }
//            else {
//                print("Activity: Update Cloud Kit record")
//                ckRecord = CKRecord.decodeCKRecordSystemFields(from: encodedCKRecord! as Data)
//            }
            let ckRecord = CKRecord.decodeCKRecordSystemFields(from: encodedCKRecord! as Data)
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
        set{
            encodedCKRecord = newValue.encodedCKRecordSystemFields
            ckRecordIdName = newValue.recordID.recordName

            completed = newValue[Keys.Completed] as? CompletedType ?? false
            completedDate = newValue[Keys.CompletedDate] as? CompletedDateType
            deferredTo = newValue[Keys.DeferredTo] as? DeferredToType
            deferredToResponseDueDate = newValue[Keys.DeferredToResponseDueDate] as? DeferredToResponseDueDateType
            displayOrder = newValue[Keys.DisplayOrder] as? DisplayOrderType ?? 0
            dueDate = newValue[Keys.DueDate] as? DueDateType
            estimatedTimeboxes = newValue[Keys.EstimatedTimeboxes] as? EstimatedTimeboxesType ?? 0
            info = newValue[Keys.Info] as? InfoType
            isSynced = newValue[Keys.IsSynced] as? IsSyncedType ?? false
//            kind = newValue[Keys.Kind] as? Kind ?? .flexible
            kind = Kind.init(rawValue: newValue[Keys.Kind] as! Int16) ?? .flexible
            name = newValue[Keys.Name] as? NameType ?? Activity.defaultName
            scheduledEnd = newValue[Keys.ScheduledEnd] as? ScheduledEndType
            scheduledStart = newValue[Keys.ScheduledStart] as? ScheduledStartType
            today = newValue[Keys.Today] as? TodayType ?? false
            todayDisplayOrder = newValue[Keys.TodayDisplayOrder] as? TodayDisplayOrderType ?? 0
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
        self.kind = .flexible

        let ckRecord = CKRecord(recordType: CloudKitClient.RecordType.Activity.rawValue)
        
        self.encodedCKRecord = ckRecord.encodedCKRecordSystemFields
        self.ckRecordIdName = ckRecord.recordID.recordName
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
        ckRecordIdName = data[Keys.CKRecordIdName] as? CKRecordIdNameType

        completed = data[Keys.Completed] as? CompletedType ?? false
        completedDate = data[Keys.CompletedDate] as? CompletedDateType
        deferredTo = data[Keys.DeferredTo] as? DeferredToType
        deferredToResponseDueDate = data[Keys.DeferredToResponseDueDate] as? DeferredToResponseDueDateType
        displayOrder = data[Keys.DisplayOrder] as? DisplayOrderType ?? 0
        dueDate = data[Keys.DueDate] as? DueDateType
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
//        let data: [AnyHashable: Any] = [
//            
//            Keys.CKRecordIdName: ckRecord.recordID.recordName,
//            Keys.Completed: ckRecord[Keys.Completed] as Any,
//            Keys.CompletedDate: ckRecord[Keys.CompletedDate] as Any,
//            Keys.DeferredTo: ckRecord[Keys.DeferredTo] as Any,
//            Keys.DeferredToResponseDueDate: ckRecord[Keys.DeferredToResponseDueDate] as Any,
//            Keys.DisplayOrder: ckRecord[Keys.DisplayOrder] as Any,
//            Keys.DueDate: ckRecord[Keys.DueDate] as Any,
//            Keys.EncodedCKRecord: ckRecord.encodedCKRecordSystemFields,
//            Keys.EstimatedTimeboxes: ckRecord[Keys.EstimatedTimeboxes] as Any,
//            Keys.Info: ckRecord[Keys.Info] as Any,
//            Keys.Kind: ckRecord[Keys.Kind] as Any,
//            Keys.Name: ckRecord[Keys.Name] as Any,
//            Keys.ScheduledEnd: ckRecord[Keys.ScheduledEnd] as Any,
//            Keys.ScheduledStart: ckRecord[Keys.ScheduledStart] as Any,
//            Keys.Today: ckRecord[Keys.Today] as Any,
//            Keys.TodayDisplayOrder: ckRecord[Keys.TodayDisplayOrder] as Any
//        ]
        let name = ckRecord[Keys.Name] as! String
        self.init(context: context, name: name)
        cloudKitRecord = ckRecord
    }

    var actualTimeboxes: Int {
        return timeboxes.count
    }
    
    /**
     Save CloudKit object
     
     save core data record then update cloud kit object.
     */
    
    
    override public func didSave() {
        
        if isDeleted {
            print("Delete \(type(of:self)) [\(self.name)] \(#function)")
            CloudKitClient.destroyActivity(self.cloudKitRecord) { (ckRecordID, error) in
                guard error == nil else {
                    print("Error deleting \(type(of:self))", error!)
                    return
                }
                print("Delete \(type(of: self)) \(String(describing: ckRecordID))")
            }
            return
        }
        
        if managedObjectContext == CoreDataStackManager.shared.mainContext {
//            print("\(type(of:self)) [\(self.name)] \(#function)")
            
            let localCKRecord: CKRecord = self.cloudKitRecord
            
            CloudKitClient.getActivity(ckRecordIdName!) { (remoteCKRecord, error) in
                guard error == nil else {
                    print("Error retrieving \(type(of:self))", error!)

                    CloudKitClient.storeActivity(localCKRecord) { (ckRecord, error) in
                        guard error == nil else {
                            print("\(type(of:self)) storeReord", error!)
                            return
                        }
                        
                        //                    print("ckRecord \(String(describing: ckRecord?.recordChangeTag))")
                        
                        self.managedObjectContext?.perform {
                            self.setPrimitiveValue(ckRecord!.encodedCKRecordSystemFields, forKey: Keys.EncodedCKRecord)
                        }
                    }
                    return
                }

                let remoteCKRecord = remoteCKRecord!
//                print("\(type(of:self)) localCKRecord", localCKRecord)
//                print("\(type(of:self)) remoteCKRecord ", remoteCKRecord)
                
                for key in remoteCKRecord.allKeys() {
                    remoteCKRecord.setObject(localCKRecord.object(forKey: key), forKey: key)
                }
                
//                print("\(type(of:self)) remoteCKRecord ", remoteCKRecord)

                CloudKitClient.storeActivity(remoteCKRecord) { (ckRecord, error) in
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
