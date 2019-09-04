//
//  DataManager.swift
//  GoogleMapsTest
//
//  Created by Boris Chirino on 04/09/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

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
}
