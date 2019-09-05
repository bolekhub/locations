//
//  MasterViewController.swift
//  Locations
//
//  Created by Boris Chirino on 05/09/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit


class MasterViewController: UISplitViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nc = viewControllers[0] as? UINavigationController, let listVc = nc.topViewController as? TrafficCamsViewController, let mapvc = viewControllers[1] as? MapViewController {
            listVc.delegate = mapvc
        }
    }
}
