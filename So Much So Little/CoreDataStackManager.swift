//
//  CoreDataStackManager.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/21/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData

class CoreDataStackManager {
    
    static let modelName = "So_Much_So_Little"
    
    static let shared: CoreDataStack = CoreDataStack(modelName: modelName)!
    
    fileprivate init() {}
    
}
