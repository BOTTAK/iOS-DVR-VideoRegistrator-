//
//  VideoOutputView.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 04/08/2019.
//  Copyright © 2019 BOTTAK. All rights reserved.
//

import UIKit
import AVFoundation

class VideoOutputView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    /// Convenience wrapper to get layer as its statically known type.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}

