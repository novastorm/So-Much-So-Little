//
//  StubTest.swift
//  So Much So Little
//
//  Created by Adland Lee on 10/21/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CloudKit
import UIKit

class StubTest: UIViewController {
    
    @IBAction func callFirstLaunch(_ sender: AnyObject) {
        print("callFirstLaunch")
        
        try! CoreDataStackManager.sharedInstance.dropAllData()

        UserDefaults.standard.set(false, forKey: AppDelegate.UserDefaultKeys.HasLaunchedBefore)

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.checkIfFirstLaunch()
    }
    
    @IBAction func getActivityList(_ sender: AnyObject) {
        print("getActivityList")
        CloudKitClient.getActivityList { (results, error) in
            
            guard error == nil else {
                print("error")
                return
            }
            print(results!)
        }
    }
    
    @IBAction func showActivity(_ sender: AnyObject) {
        print("showActivity")
    }
    
    @IBAction func storeActivity(_ sender: AnyObject) {
        print("storeActivity")
    }
}
