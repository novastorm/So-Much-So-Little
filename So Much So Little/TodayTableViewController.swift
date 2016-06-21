//
//  TodayViewController.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/14/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import UIKit

class TodayTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeBoxTallyLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
}

class TodayTableViewController: UITableViewController {

//    @IBOutlet weak var tableView: UITableView!
    
    var activities:[[String:AnyObject]] {
        return Activity.mockActivityList
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowActivityDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            let destinationVC = segue.destinationViewController as! ActivityDetailViewController
            
            destinationVC.activity = activities[indexPath.row]
        }
    }
}


// MARK: - Table View Data Source

extension TodayTableViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "TodayCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! TodayTableViewCell
        
        configureTodayCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureTodayCell(cell: TodayTableViewCell, atIndexPath indexPath: NSIndexPath) {
        let activity = activities[indexPath.row]
        let actualTimeboxes = activity[Activity.Keys.ActualTimeboxes] as? Int ?? 0
        let estimatedTimeboxes = activity[Activity.Keys.EstimatedTimeboxes] as? Int ?? 0
        
        cell.taskLabel.text = activity[Activity.Keys.Task] as? String
        cell.timeBoxTallyLabel.text = "\(actualTimeboxes)/\(estimatedTimeboxes)"
    }
}


// MARK: - Table View Delegate

extension TodayTableViewController {
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let unlist = UITableViewRowAction(style: .Normal, title: "Unlist") { (action, todayIndexPath) in
            print("\(todayIndexPath.row): Unlist tapped")
        }
        
        let complete = UITableViewRowAction(style: .Normal, title: "Complete") { (action, completeIndexPath) in
            print("\(completeIndexPath.row): Complete tapped")
        }
        
        return [unlist, complete]
    }
}