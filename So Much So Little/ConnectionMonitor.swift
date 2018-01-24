//
//  ConnectionMonitor.swift
//  So Much So Little
//
//  Created by Adland Lee on 11/6/17.
//  Copyright © 2017 Adland Lee. All rights reserved.
//

import Reachability

// MARK:  - Notifications
extension Notification.Name {
    static let ConnectionMonitorNetworkNotReachableNotification = Notification.Name("ConnectionMonitorNetworkNotReachable")
    static let ConnectionMonitorNetworkReachableNotification = Notification.Name("ConnectionMonitorNetworkReachable")
}

class ConnectionMonitor
{
    static let hostname = "8.8.8.8"
    static let shared: ConnectionMonitor = ConnectionMonitor(hostname: hostname)
    
    let reachability: Reachability!
    
    init(hostname: String? = nil) {
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
        let notificationCenter = NotificationCenter.default
        var notification: Notification!
        
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
            notification = Notification(name: .ConnectionMonitorNetworkReachableNotification, object: nil)
        case .cellular:
            print("Reachable via Cellular")
            notification = Notification(name: .ConnectionMonitorNetworkReachableNotification, object: nil)
        case .none:
            print("Network not reachable")
            notification = Notification(name: .ConnectionMonitorNetworkNotReachableNotification, object: nil)
        }
        
        notificationCenter.post(notification)
    }

    func isConnectedToNetwork() -> Bool {
        switch reachability.connection {
        case .wifi: fallthrough
        case .cellular:
            return true
        case .none:
            return false
        }
    }
}
