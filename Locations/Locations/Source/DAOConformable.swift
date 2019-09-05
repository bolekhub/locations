//
//  PlayListRepository.swift
//  VODApp
//
//  Created by Boris Chirino on 23/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation
import CoreData

/// class conforming this protocol must implement the specific storage . Ex CoreData, Memory, Realm, etc..
protocol DAOConformable: class {
    
    /// persist an array of PlayListItemVO.
    ///
    /// - Parameter items: array of CameraMetaDataVO
    func batchBackgroundSave(fromModel itemsVO: [CameraMetaDataVO], completion: @escaping (_ success: Bool) -> Void )
    
    /// get a video entity by its identifier
    ///
    /// - Parameter id: identifier
    /// - Returns: TrafficCameraItem entity
    func getBy(id: String, context: NSManagedObjectContext?) -> TrafficCameraItem?
    
    /// Get all entitiies, filtered by if is already cached.
    ///
    /// - Returns: array of cached videos
    func getAll() -> [TrafficCameraItem]?
}
