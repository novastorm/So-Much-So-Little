//
//  ActivityDetailView.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/30/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import UIKit

class ActivityDetailView: UIView {
    
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var timeboxControl: TimeboxControl!
    @IBOutlet weak var taskInfoTextView: UITextView!

    @IBOutlet weak var projectTextField: UITextField!
    @IBOutlet weak var milestoneTextField: UITextField!
    @IBOutlet weak var roleTextField: UITextField!

    @IBOutlet weak var referenceButton: UIButton!
    @IBOutlet weak var scheduledButton: UIButton!
    @IBOutlet weak var flexibleButton: UIButton!
    @IBOutlet weak var deferredButton: UIButton!

    @IBOutlet weak var scheduledFieldsView: UIView!
    @IBOutlet weak var scheduledStartTextField: UITextField!
    @IBOutlet weak var scheduledEndTextField: UITextField!
    @IBOutlet weak var attendeesTextField: UITextField!
    
    @IBOutlet weak var flexibleFieldsView: UIView!
    @IBOutlet weak var dueDateTextField: UILabel!
    
    @IBOutlet weak var deferredFieldsView: UIView!
    @IBOutlet weak var deferredToTextField: UITextField!
    @IBOutlet weak var responseDueByTextField: UITextField!
    
    @IBOutlet weak var completionFieldsView: UIView!
    @IBOutlet weak var completionDateTextField: UILabel!
    
//    var view: UIView!
    
    func setupView() {
        let view = loadView()
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        addSubview(view)
    }
    
    func loadView() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: self.dynamicType.className, bundle: bundle)
        return nib.instantiateWithOwner(self, options: nil).first as! UIView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
}
