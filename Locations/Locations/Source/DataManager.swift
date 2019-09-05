//
//  DataManager.swift
//  GoogleMapsTest
//
//  Created by Boris Chirino on 04/09/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class DataManager: NSObject {
    
    
    var api: TrafficAPIConformable?
    var dao: DAOConformable?
    
    init(api: TrafficAPIConformable, dao: DAOConformable) {
        self.api = api
        self.dao = dao
    }
    
    
    func fetchCams(parameters: Parameters?, completion:@escaping (Error?) -> Void) {
        
        self.api?.fetchCams(parameters: parameters, completion: { (response) in
            
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
    
    
    func image(_forMetadataId id: String, completion:@escaping (UIImage?) -> Void) {
        
        if let entity = self.dao?.getBy(id: id, context: nil) {
            if Date.timestamp(fromTimeInterval: entity.timestamp) < 200, let cachedImageData = entity.image {
                    completion (UIImage(data: cachedImageData))
            } else {
                self.api?.getCameraImage(forEntity: entity, completion: { (image) in
                    let imageData = image?.jpegData(compressionQuality: 1)
                    entity.image = imageData
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
