//
//  PersistentContainerMock.swift
//  So Much So LittleTests
//
//  Created by Adland Lee on 9/24/18.
//  Copyright © 2018 Adland Lee. All rights reserved.
//

import CoreData

class PersistentContainerMock {
    
    class func createInMemoryPersistentContainer(name: String = "So_Much_So_Little") -> NSPersistentContainer {
        let container = NSPersistentContainer(name: name)
        let description = NSPersistentStoreDescription()
        description.configuration = "Default"
        description.type = NSInMemoryStoreType
        
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { (persistentStoreDescription, error) in
            // empty
        })
        
        return container
    }
}
