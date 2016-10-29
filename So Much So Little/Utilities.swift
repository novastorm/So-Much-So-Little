//
//  Utilities.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/15/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import Reachability

extension NSObject {
    
    static var className: String {
        return description().components(separatedBy: ".")[1]
    }

}

func checkNetworkConnection(_ hostname: String?, completionHandler: (_ success: Bool, _ error: NSError?) -> Void) {
    
    var reachability: Reachability?
    
    reachability = (hostname == nil) ? Reachability() : Reachability(hostname: hostname!)
    
    guard let reachable = reachability?.isReachable , reachable else {
        // Debug without network
        if (UIApplication.shared.delegate as! AppDelegate).debugWithoutNetwork {
            completionHandler(true, nil)
            return
        }
        
        let userInfo: [String:AnyObject] = [
            NSLocalizedDescriptionKey: "Network not reachable" as AnyObject
        ]
        
        completionHandler(false, NSError(domain: "checkNetworkConnection", code: 1, userInfo: userInfo))
        return
    }
    
    completionHandler(true, nil)
}
