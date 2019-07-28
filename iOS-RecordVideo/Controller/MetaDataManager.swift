//
//  MetaDataViewController.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 6/20/19.
//  Copyright © 2019 BOTTAK. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import CoreLocation

class MetaDataManager {
    
    private var currentLocation: CLLocation!
    private var locManager = CLLocationManager()
    
    init() {
        checkPermissions()
    }
    
    private func checkPermissions() {
        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() ==  .authorizedAlways) {
            currentLocation = locManager.location
        }
    }
    
    open func getGPSFromVideo() -> AVMutableMetadataItem {
        let metadata = AVMutableMetadataItem()
        metadata.keySpace = AVMetadataKeySpace.quickTimeMetadata
        metadata.key = AVMetadataKey.quickTimeMetadataKeyLocationISO6709 as NSString
        metadata.identifier = AVMetadataIdentifier.quickTimeMetadataLocationISO6709
        metadata.value = String(format: "%+09.5f%+010.5f%+.0fCRSWGS_84",
                                currentLocation.coordinate.latitude,
                                currentLocation.coordinate.longitude,
                                currentLocation.altitude, currentLocation.speed) as NSString
        return metadata
    }
}
