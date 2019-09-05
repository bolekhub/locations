//
//  TrafficCamCollectionViewCell.swift
//  Locations
//
//  Created by Boris Chirino on 05/09/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class TrafficCamCollectionViewCell: UICollectionViewCell {
    
    static let identifier: String = "kTrafficCellIdentifier"
    private let highlightedColor = UIColor(rgb: 0xD8D8D8)

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    
    var shouldTintBackgroundWhenSelected = true
    var specialHighlightedArea: UIView?
    
    override var isHighlighted: Bool {
        willSet {
            onSelected(newValue)
        }
    }
    
    override var isSelected: Bool{
        willSet {
            onSelected(newValue)
        }
    }
    

    /// configure the cell ui elements
    ///
    /// - Parameter item: model element with data to populate UI
    func configure(withItem item:TrafficCameraItem){
        self.titleLabel.text = item.title
        self.regionLabel.text = item.region
        self.directionLabel.text = item.direction
    }
    
    /// control how the selection sohuld be momentary highlithed
    ///
    /// - Parameter newValue: yes or no
    func onSelected(_ newValue: Bool) {
        
        guard selectedBackgroundView == nil else { return }
        if shouldTintBackgroundWhenSelected {
            contentView.backgroundColor = newValue ? highlightedColor : UIColor.clear
        }
        if let sa = specialHighlightedArea {
            sa.backgroundColor = newValue ? UIColor.black.withAlphaComponent(0.4) : UIColor.clear
        }
    }
}
