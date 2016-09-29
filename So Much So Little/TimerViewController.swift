//
//  TimerViewController.swift
//  So Much So Little
//
//  Created by Adland Lee on 9/28/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController {
    
    @IBOutlet weak var startInterruptButton: UIButton!
    
    // MARK: - View Life Cycle
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowActivityTab" {
            print("ShowActivityTab")
            let tabBar = segue.destination as! UITabBarController
            let activityTabIndex = tabBar.childViewControllers.index(where: {$0.title == "Activity Nav"})!
            tabBar.selectedIndex = activityTabIndex
        }
    }
    

    // MARK: - Actions
    
    @IBAction func startActivityTimer(_ sender: AnyObject) {
        print("startActivityTimer")
        UIView.performWithoutAnimation {
            sender.setTitle("Interrupt", for: .normal)
            sender.removeTarget(self, action: #selector(startActivityTimer(_:)), for: .touchUpInside)
            sender.addTarget(self, action: #selector(interruptActivityTimer(_:)), for: .touchUpInside)
        }
    }
    
    @IBAction func interruptActivityTimer(_ sender: AnyObject) {
        print("interruptActivityTimer")
        UIView.performWithoutAnimation {
            sender.setTitle("Start", for: .normal)
            sender.removeTarget(self, action: #selector(interruptActivityTimer(_:)), for: .touchUpInside)
            sender.addTarget(self, action: #selector(startActivityTimer(_:)), for: .touchUpInside)
        }
    }
    
    // MARK: - Helper Functions
    
}
