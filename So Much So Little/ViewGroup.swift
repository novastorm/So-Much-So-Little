//
//  ViewGroup.swift
//  So Much So Little
//
//  Created by Adland Lee on 7/4/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import UIKit

class ViewGroup: NSObject {
    let viewList: [UIView]
    
    init(views: [UIView]) {
        
        viewList = views

        super.init()
    }
    
    func setView(_ targetView: UIView?) {
        for view in viewList {
            view.isHidden = targetView != view
        }
    }
}
