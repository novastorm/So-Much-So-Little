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
    
    let maxButtonSize = 44
    
    let timeboxSpacing = 5
    let timeboxCount = 7
    
    var timeboxButtons = [UIButton]()
    dynamic var estimatedTimeboxes = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    var completedTimeboxes = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    static let defaultTimeboxImage = UIImage(named: "TimeBox")
    static let estimatedTimeboxImage = UIImage(named: "Clock")
    static let completedTimeboxImage = UIImage(named: "FilledBox")

    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        for _ in 0 ..< timeboxCount {
            let button = UIButton()
            
            button.setImage(type(of: self).defaultTimeboxImage, for: UIControlState())
            button.setImage(type(of: self).estimatedTimeboxImage, for: .selected)
            button.setImage(type(of: self).estimatedTimeboxImage, for: [.selected, .highlighted])
            
            button.adjustsImageWhenHighlighted = false
            
            button.addTarget(self, action: #selector(TimeboxControl.timeboxButtonTapped(_:)), for: .touchDown)
            
            timeboxButtons += [button]
            
            addSubview(button)
        }
    }
    
    override func layoutSubviews() {
        
        let spacingTotal = timeboxSpacing * (timeboxCount - 1)
        let pendingButtonSize = (Int(frame.size.width) - spacingTotal) / (timeboxCount)
        let buttonSize = min(pendingButtonSize, maxButtonSize)
//        let buttonSize = maxButtonSize
        var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        
        for (index, button) in timeboxButtons.enumerated() {
            buttonFrame.origin.x = CGFloat(index * (buttonSize + timeboxSpacing))
            button.frame = buttonFrame
        }
        
        updateButtonSelectionStates()
    }
    
    override var intrinsicContentSize : CGSize {
        let spacingTotal = timeboxSpacing * (timeboxCount - 1)
        
//        let buttonSize = (Int(frame.size.width) - spacingTotal) / (timeboxCount)
        let pendingButtonSize = (Int(frame.size.width) - spacingTotal) / (timeboxCount)
        let buttonSize = min(pendingButtonSize, maxButtonSize)
//        let buttonSize = maxButtonSize
        let width = (buttonSize * timeboxCount) + spacingTotal
        
        return CGSize(width: width, height: buttonSize)
    }
    
    
    // MARK: Button Action
    
    func timeboxButtonTapped(_ button: UIButton) {
        estimatedTimeboxes = timeboxButtons.index(of: button)! + 1
        
        updateButtonSelectionStates()
    }
    
    func updateButtonSelectionStates() {
        for (index, button) in timeboxButtons.enumerated() {
            button.isSelected = index < estimatedTimeboxes
            let completed = (index < completedTimeboxes)
            if completed {
                button.setImage(type(of: self).completedTimeboxImage, for: .selected)
                button.isSelected = completed
                
            }
        }
    }
}
