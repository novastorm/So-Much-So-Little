//
//  SettingsTableViewController.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/20/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import Eureka
import UIKit

class SettingsTableViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Eureka! Form Setup
        
        form.inlineRowHideOptions = InlineRowHideOptions.AnotherInlineRowIsShown.union(.FirstResponderChanges)
        
        form
        
        +++ Section()
        
            <<< TextRow("Refresh")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = "Settings"
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
}
