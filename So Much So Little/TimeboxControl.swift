//
//  TimeboxControl.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/27/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import UIKit

class TimeboxControl: UIView {

    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.backgroundColor = UIColor.redColor()
        
        addSubview(button)
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 240, height: 44)
    }
}
