//
//  SplitController.swift
//  Locations
//
//  Created by Boris Chirino on 05/09/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import CoreGraphics

class SplitController: UISplitViewController {
    
    override func viewWillLayoutSubviews() {
        
        let widthfraction:CGFloat = 2.0
        self.preferredPrimaryColumnWidthFraction = 0.45
        let minimumWidth = min((self.view.bounds.size.width),(self.view.bounds.height))
        self.minimumPrimaryColumnWidth = minimumWidth/widthfraction
        self.maximumPrimaryColumnWidth = minimumWidth/widthfraction
        
        super.viewWillLayoutSubviews()
    }
}
