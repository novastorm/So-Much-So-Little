//
//  ActivityDataSource.swift
//  So Much So Little
//
//  Created by Adland Lee on 7/19/18.
//  Copyright © 2018 Adland Lee. All rights reserved.
//

import UIKit

protocol ActivityDataSource: ActivityCoreDataDataSource {

    static func createActivity(with options: ActivityOptions) -> Activity

    var objects: [Activity]? { get }
    
}
