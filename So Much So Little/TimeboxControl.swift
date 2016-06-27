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
    
    var timeboxButtons = [UIButton]()
    
    let timeboxSpacing = 5
    let timeBoxCount = 7

    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        for _ in 0 ..< timeBoxCount {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            button.backgroundColor = UIColor.redColor()
            button.addTarget(self, action: #selector(TimeboxControl.timeboxButtonTapped(_:)), forControlEvents: .TouchDown)
            
            timeboxButtons += [button]
            
            addSubview(button)
        }
    }
    
    override func layoutSubviews() {
        var buttonFrame = CGRect(x: 0, y: 0, width: 44, height: 44)
        
        for (index, button) in timeboxButtons.enumerate() {
            buttonFrame.origin.x = CGFloat(index * (44 + timeboxSpacing))
            button.frame = buttonFrame
        }
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 240, height: 44)
    }
    
    
    // MARK: Button Action
    
    func timeboxButtonTapped(button: UIButton) {
        print("Button pressed 👍")
    }
}
