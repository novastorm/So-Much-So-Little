//
//  TimerViewController.swift
//  So Much So Little
//
//  Created by Adland Lee on 9/28/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import CoreData
import UIKit

class TimerViewControllerDependencies: NSObject {
    
    var coreDataStack: CoreDataStack!
    
    init(
        coreDataStack: CoreDataStack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
        ) {
        self.coreDataStack = coreDataStack
    }
}

@objcMembers
class TimerViewController: UIViewController {
    
    
    let dependencies: TimerViewControllerDependencies!
    
    let DefaultTaskLabel = "Generic"
    
    // TODO: refactor to use settings
    enum Preset: Int {
        case long = 1500 // 25 * 60
        case short = 300 // 5 * 60
        case zero = 0
    }
    
    var activity: Activity?
    var timer: Timer?
    var secondsCount: Int = 0
    
    @IBOutlet weak var time10mLabel: UILabel!
    @IBOutlet weak var time01mLabel: UILabel!
    @IBOutlet weak var time10sLabel: UILabel!
    @IBOutlet weak var time01sLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UITextView!
    @IBOutlet weak var startInterruptButton: UIButton!
    
    
    // MARK: - Core Data convenience methods
    
    var coreDataStack: CoreDataStack {
        return dependencies.coreDataStack
    }

    var mainContext: NSManagedObjectContext {
        return coreDataStack.mainContext
    }
    
    lazy var temporaryContext: NSManagedObjectContext = {
        return coreDataStack.getTemporaryContext(withName: "TempActivityNote")
    }()
    
    func saveTemporaryContext() {
        coreDataStack.saveTemporaryContext(temporaryContext)
    }

    
    // MARK: - View Life Cycle
    
    @objc init?(
        coder aDecoder: NSCoder?,
        dependencies: TimerViewControllerDependencies
        ) {
        
        self.dependencies = dependencies
        
        if let aDecoder = aDecoder {
            super.init(coder: aDecoder)
        }
        else {
            super.init()
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(
            coder: aDecoder,
            dependencies: TimerViewControllerDependencies()
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowActivityTab" {
            print("ShowActivityTab")
            let tabBar = segue.destination as! UITabBarController
            let activityTabIndex = tabBar.children.firstIndex(where: {$0.title == "Activity List"})!
            tabBar.selectedIndex = activityTabIndex
        }
    }
    

    // MARK: - Actions

    @IBAction func showActivityView(_ sender: UIButton) {
        let destinationVC = storyboard!.instantiateViewController(withIdentifier: AppDelegate.Views.Main.rawValue)
        present(destinationVC, animated: true, completion: nil)
    }

    @IBAction func startActivityTimer(_ sender: AnyObject) {
        print("startActivityTimer")
        resetTimer(to: Preset.long)
        startTimer()
        showInterruptButton()
    }
    
    @IBAction func interruptActivityTimer(_ sender: AnyObject) {
        print("interruptActivityTimer")
        showInterruptAlert()
    }
    
    func showInterruptButton() {
        startInterruptButton.setTitle("Interrupt", for: .normal)
        startInterruptButton.removeTarget(self, action: #selector(startActivityTimer(_:)), for: .touchUpInside)
        startInterruptButton.addTarget(self, action: #selector(interruptActivityTimer(_:)), for: .touchUpInside)
    }
    
    func showStartButton() {
        startInterruptButton.setTitle("Start", for: .normal)
        startInterruptButton.removeTarget(self, action: #selector(interruptActivityTimer(_:)), for: .touchUpInside)
        startInterruptButton.addTarget(self, action: #selector(startActivityTimer(_:)), for: .touchUpInside)
    }
    
    func showInterruptAlert() {
        let alertController = UIAlertController(title: "Interrupt", message: "Enter interrupt info", preferredStyle: .alert)
        
        alertController.addTextField { (textfield) in
            textfield.placeholder = "Note"
        }
        
        let createActivityAction = UIAlertAction(title: "Note and Resume Task", style: .default) { _ in
            if let field = alertController.textFields?[0] {
                let infoText = field.text
                self.temporaryContext.perform {
                    let newActivity = Activity(insertInto: self.temporaryContext)
                    newActivity.info = infoText
                    self.saveTemporaryContext()
                }
            }
            else {
                print("nothing entered")
            }
        }
        
        let stopAction = UIAlertAction(title: "Stop", style: .destructive) { _ in
            self.stopTimer()
            self.resetTimer(to: .zero)
            self.showStartButton()
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
        stopTimer()
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(decrementTime), userInfo: nil, repeats: true)    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer(to seconds: Preset) {
        secondsCount = seconds.rawValue
        updateTimeLabel()
    }
    
    @objc func decrementTime() {
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
        
        time10mLabel.text = "\(minutes10)"
        time01mLabel.text = "\(minutes01)"
        time10sLabel.text = "\(seconds10)"
        time01sLabel.text = "\(seconds01)"
    }
    
    func clearActivity() {
        nameLabel.text = DefaultTaskLabel
        infoLabel.text.removeAll()
        activity = nil
    }
    
    func updateActivity() {
        guard activity != nil else {
            return
        }
        
        nameLabel.text = activity?.name
        infoLabel.text = activity?.info
    }
}
