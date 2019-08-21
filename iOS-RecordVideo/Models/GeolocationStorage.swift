//
//  GeolocationStorage.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 8/21/19.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import CoreLocation

import Foundation

class GeolocationStorage {
    var startTime: Date?
    var records = [GeolocationStorage.Record]()
    
    func add(record: GeolocationStorage.Record) {
        self.records.append(record)
    }
}

extension GeolocationStorage {
    struct Record {
        let location: CLLocation
        let timecode: Date
    }
}
