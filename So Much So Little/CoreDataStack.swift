//
//  CoreDataStack.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/15/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData
import UIKit

protocol CoreDataStack {

    typealias BatchTask=(_ workerContext: NSManagedObjectContext) -> ()

    var cloudKitClient: CloudKitClient! { get set }
    
    var mainContext: NSManagedObjectContext { get }
    
    func getTemporaryContext(withName name: String) -> NSManagedObjectContext
    
    func saveTemporaryContext(_ context: NSManagedObjectContext)
    
    func getScratchContext(withName name: String) -> NSManagedObjectContext
    
    func clearDatabase() throws
    
    func performBackgroundBatchOperation(_ batch: @escaping BatchTask)

    func saveMainContext()
    
    func savePersistingContext()
    
    func autoSave(_ interval : TimeInterval)
}
