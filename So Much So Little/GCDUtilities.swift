//
//  GCDUtilities.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/15/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
