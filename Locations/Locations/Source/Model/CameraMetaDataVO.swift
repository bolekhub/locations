//
//  CamMetaData.swift
//  GoogleMapsTest
//
//  Created by Boris Chirino on 04/09/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

enum CameraMetaDataParseError: Error {
    case keyNotFound(key :String)
}


struct CameraMetaDataVO: Codable, Equatable, Hashable {
    
    var id: String
    var direction: String
    var stringUrl: String
    var region: String
    var title: String
    var view: String
    var latitude: Double
    var longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case direction
        case stringUrl = "href"
        case region
        case title
        case view
        case latitude
        case longitude
    }
    
    //Equatable. Needed to compare two objects. are equally if both have same identifier(id) value
    static func == (lhs: CameraMetaDataVO, rhs: CameraMetaDataVO) -> Bool {
        return lhs.id == rhs.id
    }
    
    //Hashable. Used to identify object singularity in collections.
    func hash(into hasher: inout Hasher) {
        var hasher = Hasher()
        hasher.combine(id)
        let _ = hasher.finalize()
    }

}


extension CameraMetaDataVO {
    
    /// parse a json and convert it to Model object
    ///
    /// - Parameter fromJsonResponse: json object
    /// - Returns: return an array of all parsed items
    /// - Throws: throw an exception if during parsing an error occurs
    static func from(_ fromJsonResponse: Any?) throws -> [CameraMetaDataVO] {
        
        let jsonDecoder = JSONDecoder.init()
        let optionalCameraArray = (fromJsonResponse as? NSDictionary)?[kMetadataJsonKeyName]
        guard let productArray = optionalCameraArray else {
            throw CameraMetaDataParseError.keyNotFound(key: kMetadataJsonKeyName)
        }
        let productsArrayAsData = try JSONSerialization.data(withJSONObject: productArray, options: .prettyPrinted)
        return try jsonDecoder.decode([CameraMetaDataVO].self, from: productsArrayAsData)
    }
    
}
