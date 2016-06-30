//
//  TimeboxControl.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/27/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import UIKit

class TimeboxControl: UIView {
    
    // MARK: Properties
    
    let timeboxSpacing = 5
    let timeboxCount = 7
    
    var timeboxButtons = [UIButton]()
    var pendingTimeboxes = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    var completedTimeboxes = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    static let defaultTimeboxImage = UIImage(named: "Timebox")
    static let pendingTimeboxImage = UIImage(named: "Clock")
    static let completedTimeboxImage = UIImage(named: "FilledBox")

    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        for _ in 0 ..< timeboxCount {
            let button = UIButton()
            
            button.setImage(self.dynamicType.defaultTimeboxImage, forState: .Normal)
            button.setImage(self.dynamicType.pendingTimeboxImage, forState: .Selected)
            button.setImage(self.dynamicType.pendingTimeboxImage, forState: [.Selected, .Highlighted])
            
            button.adjustsImageWhenHighlighted = false
            
            button.addTarget(self, action: #selector(TimeboxControl.timeboxButtonTapped(_:)), forControlEvents: .TouchDown)
            
            timeboxButtons += [button]
            
            addSubview(button)
        }
    }
    
    override func layoutSubviews() {
        
        let spacingTotal = timeboxSpacing * (timeboxCount - 1)
        let buttonSize = (Int(frame.size.width) - 16 - spacingTotal) / (timeboxCount)
        var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        
        for (index, button) in timeboxButtons.enumerate() {
            buttonFrame.origin.x = CGFloat(index * (buttonSize + timeboxSpacing))
            button.frame = buttonFrame
        }
        
        updateButtonSelectionStates()
    }
    
    override func intrinsicContentSize() -> CGSize {
        let spacingTotal = timeboxSpacing * (timeboxCount - 1)
        
        let buttonSize = (Int(frame.size.width) - 16 - spacingTotal) / (timeboxCount)
        let width = (buttonSize * timeboxCount) + spacingTotal
        
        return CGSize(width: width, height: buttonSize)
    }
    
    
    // MARK: Button Action
    
    func timeboxButtonTapped(button: UIButton) {
        pendingTimeboxes = timeboxButtons.indexOf(button)! + 1
        
        updateButtonSelectionStates()
    }
    
    func updateButtonSelectionStates() {
        for (index, button) in timeboxButtons.enumerate() {
            button.selected = index < pendingTimeboxes
            let completed = (index < completedTimeboxes)
            if completed {
                button.setImage(self.dynamicType.completedTimeboxImage, forState: .Selected)
                button.selected = completed
                
            }
        }
    }
}
