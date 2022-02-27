//
//  ActivityDataSource.swift
//  So Much So Little
//
//  Created by Adland Lee on 7/19/18.
//  Copyright © 2018 Adland Lee. All rights reserved.
//

import UIKit

protocol ActivityDataSource {
    var fetchedObjects: [Activity]? { get }

    @discardableResult
    func createActivity(with options: ActivityOptions) -> Activity

    func performFetch() throws
    
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at: IndexPath) -> Activity
    
    func save()
    
}
