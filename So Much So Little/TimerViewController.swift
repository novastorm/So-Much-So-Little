//
//  TimerViewController.swift
//  So Much So Little
//
//  Created by Adland Lee on 9/28/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController {
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowActivityTab" {
            print("ShowActivityTab")
            let activityTabIndex = segue.destination.childViewControllers.index(where: {$0.title == "Activity Nav"})!
            let tabBar = segue.destination as! UITabBarController
            tabBar.selectedIndex = activityTabIndex
        }
    }
}
