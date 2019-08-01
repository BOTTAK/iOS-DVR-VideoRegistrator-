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
import Photos

protocol MetaDataManagerSetting: class {
    func metaDataManagerSetting(_ getGPSFromVideo: CLLocation)
}

class MetaDataManager: NSObject {
    
    private var currentLocation: CLLocation!
    private var locManager = CLLocationManager()
    private var library: PHAsset!
    
    weak var delegate: MetaDataManagerSetting?
    
    override init() {
        super.init()
        locManager.delegate = self
    }
    
    func getDataAndTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm, MMMMM, dd, yyyy, EEEE"
        let str = dateFormatter.string(from: Date())
    }
    
    
    func getGPSFromVideo() -> AVMutableMetadataItem {
        
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
             delegate?.metaDataManagerSetting(currentLocation)
             let dateData = Calendar(identifier: .gregorian)
             let componentData = dateData.dateComponents([.day,.month,.year,.hour,.minute,.second], from: Date())

             let metadata = AVMutableMetadataItem()
             
             
             metadata.keySpace = AVMetadataKeySpace.quickTimeMetadata
             metadata.key = AVMetadataKey.quickTimeMetadataKeyLocationISO6709 as NSString
             metadata.identifier = AVMetadataIdentifier.quickTimeMetadataLocationISO6709
             metadata.value = String(format: "%+09.5f%+010.5f%+.0fCRSWGS_84",
                                     currentLocation.coordinate.latitude,
                                     currentLocation.coordinate.longitude, currentLocation.speed as CVarArg) as NSString
             return metadata
        @unknown default:
            fatalError()
        }
        return AVMutableMetadataItem()
        
    }
    
    
        func _gpsMetadata(withLocation location: CLLocation) -> NSMutableDictionary {
        let f = DateFormatter()
        f.timeZone = TimeZone(abbreviation: "UTC")
        
        f.dateFormat = "yyyy:MM:dd"
        let isoDate = f.string(from: location.timestamp)
        
        f.dateFormat = "HH:mm:ss.SSSSSS"
        let isoTime = f.string(from: location.timestamp)
        
        let GPSMetadata = NSMutableDictionary()
        let altitudeRef = Int(location.altitude < 0.0 ? 1 : 0)
        let latitudeRef = location.coordinate.latitude < 0.0 ? "S" : "N"
        let longitudeRef = location.coordinate.longitude < 0.0 ? "W" : "E"
        
        // GPS metadata
        GPSMetadata[(kCGImagePropertyGPSLatitude as String)] = abs(location.coordinate.latitude)
        GPSMetadata[(kCGImagePropertyGPSLongitude as String)] = abs(location.coordinate.longitude)
        GPSMetadata[(kCGImagePropertyGPSLatitudeRef as String)] = latitudeRef
        GPSMetadata[(kCGImagePropertyGPSLongitudeRef as String)] = longitudeRef
        GPSMetadata[(kCGImagePropertyGPSAltitude as String)] = Int(abs(location.altitude))
        GPSMetadata[(kCGImagePropertyGPSAltitudeRef as String)] = altitudeRef
        GPSMetadata[(kCGImagePropertyGPSTimeStamp as String)] = isoTime
        GPSMetadata[(kCGImagePropertyGPSDateStamp as String)] = isoDate
        
        return GPSMetadata
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

