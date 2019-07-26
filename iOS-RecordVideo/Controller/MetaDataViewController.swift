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

class MetaDataViewController: UIViewController {
    
    
    var trimer = VideoTrimmer()
    var fileName: String = ""
    

    
    func getGPSFromVideo(forLocation location: CLLocation) {
        let metadata = AVMutableMetadataItem()
        metadata.keySpace = AVMetadataKeySpace.quickTimeMetadata
        metadata.key = AVMetadataKey.quickTimeMetadataKeyLocationISO6709 as NSString
        metadata.identifier = AVMetadataIdentifier.quickTimeMetadataLocationISO6709
        metadata.value = String(format: "%+09.5f%+010.5f%+.0fCRSWGS_84", location.coordinate.latitude, location.coordinate.longitude, location.altitude, location.speed) as NSString
//        trimer.trimVideo(sourceURL: fileName, trimPoints: TrimTime, completion: nil).metadata = [metadata]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    


}
