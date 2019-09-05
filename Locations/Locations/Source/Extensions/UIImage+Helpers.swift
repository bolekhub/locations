//
//  UIImage+Helpers.swift
//  Locations
//
//  Created by Boris Chirino on 05/09/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

extension UIImage {
    func resizedImage(for size: CGSize) -> UIImage? {

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

