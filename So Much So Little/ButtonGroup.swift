//
//  ButtonGroup.swift
//  So Much So Little
//
//  Created by Adland Lee on 7/4/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import Foundation
import UIKit

class ButtonGroup: NSObject {
    let buttonList: [UIButton]
    
    let defaultBackgroundColor: UIColor?
    let defaultTitleColor: UIColor?
    
    var unSelectable: Bool
    
    let selectedBackgroundColor: UIColor?
    let selectedTitleColor: UIColor?
    
    var selectedButton: UIButton?
    
    init(buttons: [UIButton], backgroundColor: UIColor?, titleColor: UIColor?, unSelectable: Bool = false) {
        
        selectedBackgroundColor = backgroundColor
        selectedTitleColor = titleColor
        
        buttonList = buttons
        self.unSelectable = unSelectable
        defaultBackgroundColor = buttons[0].backgroundColor
        defaultTitleColor = buttons[0].titleColorForState(.Normal)
        
        super.init()

        for button in buttons {
            button.addTarget(self, action: #selector(ButtonGroup.didTouchUpInside(_:)), forControlEvents: .TouchUpInside)
        }
        
        if unSelectable {
            didTouchUpInside(buttons[0])
        }
    }
    
    func didTouchUpInside(button: UIButton) {
        for button in buttonList {
            button.backgroundColor = defaultBackgroundColor
            button.setTitleColor(defaultTitleColor, forState: .Normal)
        }
        
        if selectedButton == nil || unSelectable || selectedButton != button {
            button.backgroundColor = selectedBackgroundColor
            button.setTitleColor(selectedTitleColor, forState: .Normal)
            selectedButton = button
        }
        else {
            selectedButton = nil
        }
    }
}