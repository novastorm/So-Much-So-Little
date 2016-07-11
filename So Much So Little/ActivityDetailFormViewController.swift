//
//  ActivityDetailFormViewController.swift
//  So Much So Little
//
//  Created by Adland Lee on 7/9/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import Eureka
import UIKit

class ActivityDetailFormViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        form
            +++ Section()
                <<< TextRow("Activity Label").cellSetup { (cell, row) in
                    cell.textField.placeholder = row.tag
                }
        
//                <<< TextRow("Location").cellSetup { (cell, row) in
//                    cell.textField.placeholder = row.tag
//                }
                <<< TimeboxControlRow()
    }
}