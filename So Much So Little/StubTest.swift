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
    
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var coreDataStack: CoreDataStack {
        return CoreDataStackManager.shared
    }
    
    @IBAction func callFirstLaunch(_ sender: AnyObject) {
        print("callFirstLaunch")
        
        try! coreDataStack.dropAllData()

        UserDefaults.standard.set(false, forKey: AppDelegate.UserDefaultKeys.HasLaunchedBefore)

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
