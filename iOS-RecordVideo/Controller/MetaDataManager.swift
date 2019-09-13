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

protocol MetaDataDelegate: class {
    func metadataDidUpdate(_ getGPSFromVideo: CLLocation)
}

class MetaDataManager: NSObject {
    
    var geolocationStorage: GeolocationStorage?
    
    private var currentLocation: CLLocation!
    private var locManager = CLLocationManager()
    private var library: PHAsset!
    private var dateFormatter = DateFormatter()
    
    weak var delegate: MetaDataDelegate?
    
    override init() {
        super.init()
        locManager.delegate = self
//        locManager.desiredAccuracy = kCLLocationAccuracyBest
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        getGPSFromVideo()
    }
    
    func getGPSFromVideo() {
        locManager.startUpdatingLocation()
        locManager.requestLocation()
        currentLocation = locManager.location
        delegate?.metadataDidUpdate(currentLocation)
        locManager.stopUpdatingLocation()
    }
    
    func getLocation() -> (CLLocation, String) {
        locManager.startUpdatingLocation()
        locManager.requestLocation()
        let formatterDate = dateFormatter.string(from: Date())
        locManager.stopUpdatingLocation()
        return (locManager.location ?? CLLocation(), formatterDate)
    }
    

    func convertMStoKH() {
        getGPSFromVideo()
        let mySpeed = currentLocation.speed
        let kMH = mySpeed * 3.6
    }


    func generateMetadata() -> [AVMetadataItem] {

        let metadata = AVMutableMetadataItem()
        metadata.keySpace = AVMetadataKeySpace.quickTimeMetadata
        metadata.key = AVMetadataKey.quickTimeMetadataKeyLocationISO6709 as NSString
        metadata.identifier = AVMetadataIdentifier.quickTimeMetadataLocationISO6709

//        var kmSpeed = currentLocation.speed
//        metadata.extraAttributes = [AVMetadataExtraAttributeKey.info: kmSpeed.description]
        
//        if kmSpeed < 0 {
//            kmSpeed = 0
//        }
       

        metadata.value = "\(currentLocation.coordinate.latitude)+\(currentLocation.coordinate.longitude)+\(currentLocation.altitude)" as NSString
        print(metadata.value)
        
        let metadataSpeed = AVMutableMetadataItem()
        metadataSpeed.keySpace = .quickTimeMetadata
        metadataSpeed.key = AVMetadataKey.quickTimeMetadataKeyTitle as NSString
        metadataSpeed.identifier = AVMetadataIdentifier.quickTimeMetadataTitle

//        let kmSpeed = (currentLocation.speed * 3.6)

        var speed = currentLocation.speed
        if speed < 0 { speed = 0 }
        let kmSpeed = (speed * 3.6)

        metadataSpeed.value = "\(kmSpeed)" as NSString
        print(metadataSpeed.value)
        
        let dateMetadata = AVMutableMetadataItem()
        dateMetadata.keySpace = AVMetadataKeySpace.quickTimeMetadata
        dateMetadata.key = AVMetadataKey.quickTimeMetadataKeyCreationDate as NSString
        dateMetadata.identifier = AVMetadataIdentifier.quickTimeMetadataCreationDate
        dateMetadata.value = currentLocation.timestamp.description as NSString
        print(dateMetadata.value)
        
        let metadataArray = [metadata, metadataSpeed, dateMetadata]
        return metadataArray
    }
    
    
    func XXRadiansToDegrees(radians: Double) -> Double {
        return radians * 180.0 / .pi
    }
    
    func getBearingBetweenTwoPoints(point1 : CLLocation, point2 : CLLocation) -> Double {
        // Returns a float with the angle between the two points
        let x = point1.coordinate.longitude - point2.coordinate.longitude
        let y = point1.coordinate.latitude - point2.coordinate.latitude
        
        return fmod(XXRadiansToDegrees(radians: atan2(y, x)), 360.0) + 90.0
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
        if let location = locations.first {
//            let accuracy = location.horizontalAccuracy
//            guard accuracy < 3 else { return }
            self.geolocationStorage?.add(record: GeolocationStorage.Record(location: location, timecode: Date()))
            print("location:: \(location)")
        }
    }
}


