//
//  Date+Helpers.swift
//  Locations
//
//  Created by Boris Chirino on 05/09/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

extension Date {
    
    static func timeStamp() -> TimeInterval {
        let now = Date.init()
        return now.timeIntervalSince1970
    }
    
    func seconds(toDate date: Date) -> Int {
        let userCalendar = Calendar.current
        let difference = userCalendar.dateComponents([.second], from: self, to: date)
        return difference.second ?? 0
    }
}
