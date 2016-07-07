//
//  ViewGroup.swift
//  So Much So Little
//
//  Created by Adland Lee on 7/4/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import Foundation
import UIKit

class ViewGroup: NSObject {
    let viewList: [UIView]
    
    init(views: [UIView]) {
        
        viewList = views

        super.init()
    }
    
    func setView(targetView: UIView?) {
        for view in viewList {
            view.hidden = targetView != view
        }
    }
}