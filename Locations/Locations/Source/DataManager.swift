//
//  DataManager.swift
//  GoogleMapsTest
//
//  Created by Boris Chirino on 04/09/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

/// This class is a coordinator handling api and data access
class DataManager: NSObject {
    
    var api: TrafficAPIConformable?
    var dao: DAOConformable?
    
    init(api: TrafficAPIConformable, dao: DAOConformable) {
        self.api = api
        self.dao = dao
    }
    
    
    /// get all camera metadata
    ///
    /// - Parameters:
    ///   - parameters: reserved.
    ///   - completion: if succedd error must be nil, if not the error describing the problem
    func fetchCams( completion:@escaping (Error?) -> Void) {
        
        self.api?.fetchCams( completion: { (response) in
            
            switch response {
                case .success(let items):
                    print("success")
                    self.dao?.batchBackgroundSave(fromModel: items!, completion: { (success) in
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    })
                case .failure(let error):
                    print("error")
                    DispatchQueue.main.async {
                        completion(error)
                    }
            }
        })
    }
    
    
    /// get the image for the trafficMetadata identifier. Preconditions are, image should be in cache and less than 30 seconds ago.
    /// if that conditions are not meet the image is downloaded from origin again and stored
    ///
    /// - Parameters:
    ///   - id: identifier of the object
    ///   - completion: return an image if succedd or nil elsewere
    func image(_forMetadataId id: String, completion:@escaping (UIImage?) -> Void) {
        
        let now = Date.init()
        
        if let entity = self.dao?.getBy(id: id, context: nil) {
            
            if ((entity.time?.seconds(toDate: now))!) < 30, let cachedImageData = entity.image {
                    completion (UIImage(data: cachedImageData))
            } else {
                self.api?.getCameraImage(forEntity: entity, completion: { (image) in
                    let imageData = image?.jpegData(compressionQuality: 1)
                    entity.image = imageData
                    entity.time = Date.init()
                    do {
                        try CoreDataDAO.shared.mainContext?.save()
                    } catch {
                        
                    }
                    completion(image)
                })
            }
        }
        
    
    }
}
