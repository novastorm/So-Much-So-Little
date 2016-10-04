//
//  TimerViewController.swift
//  So Much So Little
//
//  Created by Adland Lee on 9/28/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData
import UIKit

class TimerViewController: UIViewController {
    
    let DefaultTaskLabel = "Generic"
    
    // TODO: refactor to use settings
    enum Preset: Int {
        case long = 1500 // 25 * 60
        case short = 300 // 5 * 60
    }
    
    var activity: Activity?
    var timer = Timer()
    var secondsCount: Int = 0
    
    @IBOutlet weak var time10Label: UILabel!
    @IBOutlet weak var time01Label: UILabel!
    @IBOutlet weak var time10sLabel: UILabel!
    @IBOutlet weak var time01sLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var taskInfoLabel: UITextView!
    @IBOutlet weak var startInterruptButton: UIButton!
    
    
    // MARK: - Core Data convenience methods
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.mainContext
    }
    
    lazy var temporaryContext: NSManagedObjectContext = {
        return CoreDataStackManager.getTemporaryContext(withName: "TempActivityNote")
    }()
    
    func saveTemporaryContext() {
        CoreDataStackManager.saveTemporaryContext(temporaryContext)
    }

    
    // MARK: - View Life Cycle
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowActivityTab" {
            print("ShowActivityTab")
            let tabBar = segue.destination as! UITabBarController
            let activityTabIndex = tabBar.childViewControllers.index(where: {$0.title == "Activity List"})!
            tabBar.selectedIndex = activityTabIndex
        }
    }
    

    // MARK: - Actions
    
    @IBAction func startActivityTimer(_ sender: AnyObject) {
        print("startActivityTimer")
        sender.setTitle("Interrupt", for: .normal)
        sender.removeTarget(self, action: #selector(startActivityTimer(_:)), for: .touchUpInside)
        sender.addTarget(self, action: #selector(interruptActivityTimer(_:)), for: .touchUpInside)
        resetTimer(to: Preset.long)
        startTimer()
    }
    
    @IBAction func interruptActivityTimer(_ sender: AnyObject) {
        print("interruptActivityTimer")
        sender.setTitle("Start", for: .normal)
        sender.removeTarget(self, action: #selector(interruptActivityTimer(_:)), for: .touchUpInside)
        sender.addTarget(self, action: #selector(startActivityTimer(_:)), for: .touchUpInside)
        showInterruptAlert()
    }
    
    func showInterruptAlert() {
        let alertController = UIAlertController(title: "Interrupt", message: "Enter interrupt info", preferredStyle: .alert)
        
        alertController.addTextField { (textfield) in
            textfield.placeholder = "Note"
        }
        
        let createActivityAction = UIAlertAction(title: "Note and Resume Task", style: .default) { _ in
            if let field = alertController.textFields?[0] {
                let newActivity = Activity(context: self.temporaryContext)
                self.temporaryContext.perform {
                    newActivity.task_info = field.text
                    self.saveTemporaryContext()
                }
            }
            else {
                print("nothing entered")
            }
        }
        
        let stopAction = UIAlertAction(title: "Stop", style: .destructive) { _ in
            self.stopTimer()
        }
        let resumeAction = UIAlertAction(title: "Resume Task", style: .cancel)
        
        alertController.addAction(createActivityAction)
        alertController.addAction(stopAction)
        alertController.addAction(resumeAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Helper Functions
    
    func startTimer() {
        let interval = 1.0
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(decrementTime), userInfo: nil, repeats: true)    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    func resetTimer(to seconds: Preset) {
        secondsCount = seconds.rawValue
        updateTimeLabel()
    }
    
    func decrementTime() {
        secondsCount -= 1
        
        updateTimeLabel()
        
        if secondsCount <= 0 {
            stopTimer()
        }
    }
    
    func updateTimeLabel() {
        let minutes = secondsCount / 60
        let seconds = secondsCount % 60
        
        let minutes10 = minutes / 10
        let minutes01 = minutes % 10
        let seconds10 = seconds / 10
        let seconds01 = seconds % 10
        
        time10Label.text = minutes10 > 0 ? "\(minutes10)" : ""
        time01Label.text = "\(minutes01)"
        time10sLabel.text = "\(seconds10)"
        time01sLabel.text = "\(seconds01)"
    }
    
    func clearActivity() {
        taskLabel.text = DefaultTaskLabel
        taskInfoLabel.text.removeAll()
        activity = nil
    }
    
    func updateActivity() {
        guard activity != nil else {
            return
        }
        
        taskLabel.text = activity?.task
        taskInfoLabel.text = activity?.task_info
    }
}
