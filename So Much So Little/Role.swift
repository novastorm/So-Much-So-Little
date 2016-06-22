//
//  Role.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/20/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import Foundation
import CoreData


class Role: NSManagedObject {

    struct Keys {
        static let Label = "label"
        
        static let Activities = "activities"
        static let Projects = "projects"
    }
}
