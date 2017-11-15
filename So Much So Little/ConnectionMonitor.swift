//
//  ConnectionMonitor.swift
//  So Much So Little
//
//  Created by Adland Lee on 11/6/17.
//  Copyright © 2017 Adland Lee. All rights reserved.
//

import Reachability

class ConnectionMonitor
{
    let reachability: Reachability?
    
    init?(hostname: String? = nil) {
        reachability = (hostname == nil) ? Reachability() : Reachability(hostname: hostname!)
        
        do{
            try reachability!.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
    }
    
    @objc
    func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
        case .cellular:
            print("Reachable via Cellular")
        case .none:
            print("Network not reachable")
        }
    }

}
