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

struct Parameters: Encodable  {
    var lat: CLLocationDegrees
    var lon: CLLocationDegrees
    
    enum CodingKeys: String, CodingKey {
        case lat
        case lon
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lat, forKey: .lat)
        try container.encode(lon, forKey: .lon)
    }
}

typealias APIResponse =  Result<[CameraMetaDataVO]?, Error>

/// interface exposing web service contract
protocol TrafficAPIConformable: class {
    func fetchCams(parameters: Parameters?, completion:@escaping (APIResponse)->Void)
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
        
        return Configuration.serverURL
    }()
    
    
    
    
    /// get all traffic cameras metadata
    ///
    /// - Parameters:
    ///   - parameters: reserved
    ///   - completion: response containing APIResponse
    func fetchCams(parameters: Parameters? = nil, completion:@escaping (APIResponse)->Void) {
        
        // let strParams = String(format: "sql?q=SELECT id, direction, href, region, title, view, %.4f, %.4f FROM ios_test", parameters?.lon ?? 151.20, parameters?.lat ?? -33.86)
        
        let dataRequest =
            AF.request(TrafficAPI.default.endpoint!,
                       method: .get,
                       parameters: parameters,
                       encoder: URLEncodedFormParameterEncoder(destination: .queryString))
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
