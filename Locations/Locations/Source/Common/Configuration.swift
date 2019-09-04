//
//  Configuration.swift
//  Locations
//
//  Created by Boris Chirino on 05/09/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

class Configuration {
    
    fileprivate static let bundle = Bundle.main
    
    static var serverURL: URL? {
        get {
            if let sUrl = Configuration.bundle.object(forInfoDictionaryKey: kServerURLKey) as? String {
                return URL(string: sUrl)
            }
            return nil
        }
    }
    
    private init () {}
}
