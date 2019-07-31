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

class MetaDataManager: NSObject {
    
    private var currentLocation: CLLocation!
    private var locManager = CLLocationManager()
    
    override init() {
        super.init()
        locManager.delegate = self
    }
    
    open func getGPSFromVideo() -> AVMutableMetadataItem {
        
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .notDetermined:
            locManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            print("no permissions")
        case .authorizedAlways, .authorizedWhenInUse:
             locManager.startUpdatingLocation()
             locManager.requestLocation()
             currentLocation = locManager.location
             
             let dateData = Calendar(identifier: .gregorian)
             var componentData = dateData.dateComponents([.day,.month,.year,.hour,.minute,.second], from: Date())
             
             let metadata = AVMutableMetadataItem()
             
             metadata.keySpace = AVMetadataKeySpace.quickTimeMetadata
             metadata.key = AVMetadataKey.quickTimeMetadataKeyLocationISO6709 as NSString
             metadata.identifier = AVMetadataIdentifier.quickTimeMetadataLocationISO6709
             metadata.value = String(format: "%+09.5f%+010.5f%+.0fCRSWGS_84",
                                     currentLocation.coordinate.latitude,
                                     currentLocation.coordinate.longitude, currentLocation.speed,
                                     componentData as CVarArg) as NSString
             return metadata
        @unknown default:
            fatalError()
        }
        return AVMutableMetadataItem()
        
    }
}
extension MetaDataManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() ==  .authorizedAlways) {
            locManager.requestLocation()
            currentLocation = locManager.location
        } else {
            locManager.requestLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.first != nil {
            print("location:: (location)")
        }
        
    }
}
