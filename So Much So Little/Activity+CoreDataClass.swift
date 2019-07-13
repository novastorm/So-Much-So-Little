//
//  Activity+CoreDataClass.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/14/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CloudKit
import CoreData
import UIKit

@objc
class ActivityOptions: NSObject, Codable {
    var completed: Activity.CompletedType
    var completedDate: Activity.CompletedDateType?
    var deferredTo: Activity.DeferredToType?
    var deferredToResponseDueDate: Activity.DeferredToResponseDueDateType?
    var displayOrder: Activity.DisplayOrderType
    var dueDate: Activity.DueDateType?
    var estimatedTimeboxes: Activity.EstimatedTimeboxesType
    var info: Activity.InfoType?
    var kind: Activity.Kind
    var name: Activity.NameType
    var scheduledEnd: Activity.ScheduledEndType?
    var scheduledStart: Activity.ScheduledStartType?
    var today: Activity.TodayType
    var todayDisplayOrder: Activity.TodayDisplayOrderType
    
    enum CodingKeys: String, CodingKey {
        case
        completed,
        completedDate,
        deferredTo,
        deferredToResponseDueDate,
        displayOrder,
        dueDate,
        estimatedTimeboxes,
        info,
        kind,
        name,
        scheduledEnd,
        scheduledStart,
        today,
        todayDisplayOrder
    }

    init(
        completed: Activity.CompletedType = false,
        completedDate: Activity.CompletedDateType? = nil,
        deferredTo: Activity.DeferredToType? = nil,
        deferredToResponseDueDate: Activity.DeferredToResponseDueDateType? = nil,
        displayOrder: Activity.DisplayOrderType = 0,
        dueDate: Activity.DueDateType? = nil,
        estimatedTimeboxes: Activity.EstimatedTimeboxesType = 0,
        info: Activity.InfoType? = nil,
        kind: Activity.Kind = .flexible,
        name: Activity.NameType = Activity.defaultName,
        scheduledEnd: Activity.ScheduledEndType? = nil,
        scheduledStart: Activity.ScheduledStartType? = nil,
        today: Activity.TodayType = false,
        todayDisplayOrder: Activity.TodayDisplayOrderType = 0
        ) {
        self.completed = completed
        self.completedDate = completedDate
        self.deferredTo = deferredTo
        self.deferredToResponseDueDate = deferredToResponseDueDate
        self.displayOrder = displayOrder
        self.dueDate = dueDate
        self.estimatedTimeboxes = estimatedTimeboxes
        self.info = info
        self.kind = kind
        self.name = name
        self.scheduledEnd = scheduledEnd
        self.scheduledStart = scheduledStart
        self.today = today
        self.todayDisplayOrder = todayDisplayOrder
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(completed, forKey: .completed)
        try container.encode(completedDate, forKey: .completedDate)
        try container.encode(deferredTo, forKey: .deferredTo)
        try container.encode(deferredToResponseDueDate, forKey: .deferredToResponseDueDate)
        try container.encode(displayOrder, forKey: .displayOrder)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(estimatedTimeboxes, forKey: .estimatedTimeboxes)
        try container.encode(info, forKey: .info)
        try container.encode(kind, forKey: .kind)
        try container.encode(name, forKey: .name)
        try container.encode(scheduledStart, forKey: .scheduledStart)
        try container.encode(scheduledEnd, forKey: .scheduledEnd)
        try container.encode(today, forKey: .today)
        try container.encode(todayDisplayOrder, forKey: .todayDisplayOrder)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(Activity.NameType.self, forKey: .name)
        info = try? container.decode(Activity.InfoType.self, forKey: .info)
        estimatedTimeboxes = try container.decode(Activity.EstimatedTimeboxesType.self, forKey: .estimatedTimeboxes)
        displayOrder = try container.decode(Activity.DisplayOrderType.self, forKey: .displayOrder)
        
        today = try container.decode(Activity.TodayType.self, forKey: .today)
        todayDisplayOrder = try container.decode(Activity.TodayDisplayOrderType.self, forKey: .todayDisplayOrder)
        
        completed = try container.decode(Activity.CompletedType.self, forKey: .completed)
        completedDate = try? container.decode(Activity.CompletedDateType.self, forKey: .completedDate)
        
        kind = try container.decode(Activity.Kind.self, forKey: .kind)
        switch kind {
        case .deferred:
            deferredTo = try container.decode(Activity.DeferredToType.self, forKey: .deferredTo)
            deferredToResponseDueDate = try container.decode(Activity.DeferredToResponseDueDateType.self, forKey: .deferredToResponseDueDate)
        case .reference:
            break
        case .scheduled:
            scheduledStart = try? container.decode(Activity.ScheduledStartType.self, forKey: .scheduledStart)
            scheduledEnd = try? container.decode(Activity.ScheduledEndType.self, forKey: .scheduledEnd)
        case .flexible:
            dueDate = try? container.decode(Activity.DueDateType.self, forKey: .dueDate)
        }
    }
}

final public class Activity: NSManagedObject, CloudKitManagedObject {    
    
    @objc // <- required for Core Data type compatibility
    public enum Kind: Int16, CustomStringConvertible, Codable {

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
        static let EncodedCKRecord = "encodedCKRecord"
        static let CKRecordIdName = "ckRecordIdName"
        
        static let Completed = "completed"
        static let CompletedDate = "completedDate"
        static let DeferredTo = "deferredTo"
        static let DeferredToResponseDueDate = "deferredToResponseDueDate"
        static let DisplayOrder = "displayOrder"
        static let DueDate = "dueDate"
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
    
    public typealias EncodedCKRecordType = Data
    public typealias CKRecordIdNameType = String
    
    public typealias CompletedType = Bool
    public typealias CompletedDateType = Date
    public typealias DeferredToType = String
    public typealias DeferredToResponseDueDateType = Date
    public typealias DisplayOrderType = Int16
    public typealias DueDateType = Date
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
    
    @nonobjc
    var cloudKitClient: CloudKitClient {
        var delegate: AppDelegate!
        if Thread.isMainThread {
            delegate = UIApplication.shared.delegate as? AppDelegate
        }
        else {
            DispatchQueue.main.sync {
                delegate = UIApplication.shared.delegate as? AppDelegate
            }
        }
        return delegate.cloudKitClient
    }

    var actualTimeboxes: Int {
        return timeboxes.count
    }

    var cloudKitRecord: CKRecord {
        get {
            let ckRecord = CKRecord.decodeCKRecordSystemFields(from: encodedCKRecord! as Data)!
            
            for (key, _) in self.entity.attributesByName {
                ckRecord.setValue(value(forKey: key), forKey: key)
            }
            
            if let project = project {
                let ckRecordRef = CKRecord.decodeCKRecordSystemFields(from: project.encodedCKRecord! as Data)!
                ckRecord[Keys.Project] = CKRecord.Reference(record: ckRecordRef, action: .none)
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
            kind = Kind.init(rawValue: newValue[Keys.Kind] as! Int16) ?? .flexible
            name = newValue[Keys.Name] as? NameType ?? Activity.defaultName
            scheduledEnd = newValue[Keys.ScheduledEnd] as? ScheduledEndType
            scheduledStart = newValue[Keys.ScheduledStart] as? ScheduledStartType
            today = newValue[Keys.Today] as? TodayType ?? false
            todayDisplayOrder = newValue[Keys.TodayDisplayOrder] as? TodayDisplayOrderType ?? 0
        }
    }

    /**
     Create an instance from the given ActivityOptions
     
     - parameters:
         - context:
         The context into which the new instance is inserted.
         - options:
         The ActivityOptions record
     */
    
    @discardableResult
    convenience init(
        insertInto context: NSManagedObjectContext,
        with options: ActivityOptions = ActivityOptions()
        ) {
        
        let typeName = type(of: self).typeName
        let entity = NSEntityDescription.entity(forEntityName: typeName, in: context)!
        
        self.init(entity: entity, insertInto: context)
        
        let ckRecord = CKRecord(recordType: CloudKitClient.RecordType.Activity.rawValue)
        
        encodedCKRecord = ckRecord.encodedCKRecordSystemFields
        ckRecordIdName = ckRecord.recordID.recordName

        completed = options.completed
        completedDate = options.completedDate
        deferredTo = options.deferredTo
        deferredToResponseDueDate = options.deferredToResponseDueDate
        displayOrder = options.displayOrder
        dueDate = options.dueDate
        estimatedTimeboxes = options.estimatedTimeboxes
        info = options.info
        kind = options.kind
        name = options.name
        scheduledEnd = options.scheduledEnd
        scheduledStart = options.scheduledStart
        today = options.today
        todayDisplayOrder = options.todayDisplayOrder

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
    
    @discardableResult
    convenience init(
        insertInto context: NSManagedObjectContext,
        with ckRecord: CKRecord
        ) {
        
        let name = ckRecord[Keys.Name] as! String
        self.init(insertInto: context, with: ActivityOptions(name: name))
        cloudKitRecord = ckRecord
    }
    
    /**
     Save CloudKit object
     
     save core data record then update cloud kit object.
     */
    override public func didSave() {
        
        guard Thread.isMainThread else { return }
        
//        print("\(type(of:self)) [\(self.name)] \(#function)")
        
        if isDeleted {
//            print("Delete \(type(of:self)) [\(self.name)] \(#function)")
            
            showNetworkActivityIndicator()
            
            cloudKitClient.destroyRecord(self.cloudKitRecord) { (ckRecordID, error) in
                hideNetworkActivityIndicator()
                guard error == nil else {
                    print("Error deleting \(type(of:self))", error!)
                    return
                }
//                print("Delete \(type(of: self)) \(String(describing: ckRecordID))")
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
        cloudKitClient.getRecord(byId: CKRecord.ID(recordName: ckRecordIdName!)) { (remoteCKRecord, error) in
            hideNetworkActivityIndicator()
            guard error == nil else {
//                print("Error retrieving \(type(of:self))", error!)
                
                guard ConnectionMonitor.shared.isConnectedToNetwork() else {
                    self.managedObjectContext?.perform {
                        self.setPrimitiveValue(NSNumber.init(value: false), forKey: Keys.IsSynced)
                    }
                    return
                }
                
                showNetworkActivityIndicator()
                self.cloudKitClient.storeRecord(localCKRecord) { (ckRecord, error) in
                    performUIUpdatesOnMain {
                        hideNetworkActivityIndicator()
                    }
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
            remoteCKRecord.setObject(localCKRecord.object(forKey: Activity.Keys.Project), forKey: Activity.Keys.Project)
//            print("\(type(of:self)) remoteCKRecord ", remoteCKRecord)
            
            showNetworkActivityIndicator()
            self.cloudKitClient.storeRecord(remoteCKRecord) { (ckRecord, error) in
                hideNetworkActivityIndicator()
                guard error == nil else {
                    print("\(type(of:self)) storeRecord", error!)
                    return
                }
                
//                print("ckRecord \(String(describing: ckRecord?.recordChangeTag))")
                
                self.managedObjectContext?.perform {
                    self.setPrimitiveValue(ckRecord!.encodedCKRecordSystemFields, forKey: Keys.EncodedCKRecord)
                }
            }
        }
    }
}
