//
//  ActivityDataSourceMock.swift
//  So Much So Little
//
//  Created by Adland Lee on 7/19/18.
//  Copyright © 2018 Adland Lee. All rights reserved.
//

import CoreData
import UIKit

@testable import So_Much_So_Little

//@objc
class ActivityDataSource_mock: ActivityDataSource_v1 {

    // MARK: - Mock Properties
    
    var storeWasCalled = false
    var updateWasCalled = false
    var destroyWasCalled = false
    
    
    // MARK: - Initializers
    
    init() {
        super.init(
            coreDataStack: CoreDataStack_mock()!,
            cloudKitClient: CloudKitClient_mock())
    }

//    @discardableResult
//    override func store(with options: ActivityOptions) -> Activity {
//        storeWasCalled = true
//        return super.store(with: options)
//    }
//
//    override func update(_ activity: Activity) {
//        updateWasCalled = true
//        return super.update(activity)
//    }
//
//    override func destroy(_ activity: Activity) {
//        destroyWasCalled = true
//        return super.destroy(activity)
//    }
    
    private class SectionInfo: NSFetchedResultsSectionInfo {
        var name: String
        var indexTitle: String?
        var numberOfObjects: Int
        var objects: [Any]?
        
        init(name: String, indexTitle: String? = nil, numberOfObjects: Int, objects: [Any]? = nil) {
            self.name = name
            self.indexTitle = indexTitle
            self.numberOfObjects = numberOfObjects
            self.objects = objects
        }
    }
}
