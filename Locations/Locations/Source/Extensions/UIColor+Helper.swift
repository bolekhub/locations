//
//  UIColor+Helper.swift
//  Locations
//
//  Created by Boris Chirino on 05/09/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(rgb: Int, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgb & 0xFF00) >> 8) / 255.0, blue: CGFloat(rgb & 0xFF) / 255.0, alpha: alpha)
    }
}
