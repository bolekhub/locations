//
//  TrafficAPI.swift
//  Locations
//
//  Created by Boris Chirino on 05/09/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

import Foundation
import Alamofire
import MapKit


typealias APIResponse =  Result<[CameraMetaDataVO]?, Error>

/// interface exposing web service contract
protocol TrafficAPIConformable: class {
    func fetchCams(completion:@escaping (APIResponse)->Void)
    func getCameraImage(forEntity entity: TrafficCameraItem, completion:@escaping (UIImage?) -> Void)
}

/// Class to handle all network request
class TrafficAPI: NSObject, TrafficAPIConformable {
    
    public static let `default`: TrafficAPI = {
        let _ps = TrafficAPI()
        return _ps
    }()
    
    /// Depending on the scheme, it will use the local json or internet url.
    lazy var endpoint: URL? = {
        let serverurl = Configuration.serverURL
        
        if (serverurl?.host == nil) {
            let bundle = Bundle.main
            let filename = serverurl?.path.split(separator: ".")[0]
            if let optionalFileEndpoint = bundle.path(forResource: filename?.description, ofType: "json") {
                let fileUrlendpoint = URL(fileURLWithPath: optionalFileEndpoint)
                return fileUrlendpoint
            }
            return nil
        }
        
        return serverurl
    }()
    
    
    
    
    /// get all traffic cameras metadata
    ///
    /// - Parameters:
    ///   - parameters: reserved
    ///   - completion: response containing APIResponse
    func fetchCams(completion:@escaping (APIResponse)->Void) {
        
        let strParams = "SELECT id,direction,href,region,title,view,ST_X(the_geom)aslongitude,ST_Y(the_geom)aslatitude FROM ios_test"
        
        var requestURL = TrafficAPI.default.endpoint!
        
        if (TrafficAPI.default.endpoint?.host != nil) {
            let finalUrl = requestURL.appending("q", value: strParams)
            requestURL = finalUrl
        }
        
        let dataRequest =
            AF.request(requestURL,
                       method: .get, parameters: nil, encoding: URLEncoding.default)
                .validate()
                .responseJSON { (response) in
                    switch response.result {
                    case .success(let r):
                        do {
                            let items = try CameraMetaDataVO.from(r)
                            completion(APIResponse.success(items))
                        }catch {
                            completion(APIResponse.failure(error))
                        }
                    case .failure(let error):
                        completion(APIResponse.failure(error))
                    }
        }
        dataRequest.resume()
    }
    
    
    func getCameraImage(forEntity entity: TrafficCameraItem, completion:@escaping (UIImage?) -> Void) {
        AF.download(entity.url!)
            .responseData { (response) in
                do {
                    let im = try UIImage(data: response.result.get())
                    completion(im)
                }catch {
                    completion(nil)
                    print("error \(error.localizedDescription)")
                }
        }
    }
    
    
    
}
