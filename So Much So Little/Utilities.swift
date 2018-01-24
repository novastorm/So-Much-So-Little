//
//  Utilities.swift
//  So Much So Little
//
//  Created by Adland Lee on 6/15/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import Reachability


func showNetworkAlert(_ vc: UIViewController) {
    let networkErrorTitle = "Network unreachable."
    let networkErrorMessage = "Check network connection"
    
    let alertController = UIAlertController(title: networkErrorTitle, message: networkErrorMessage, preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
    alertController.addAction(okAction)
    
    alertController.view.layoutIfNeeded()
    
    vc.present(alertController, animated: true, completion: nil)
}

