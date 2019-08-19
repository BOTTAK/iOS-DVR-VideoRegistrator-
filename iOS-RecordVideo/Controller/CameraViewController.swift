//
//  CameraViewController.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 7/16/19.
//  Copyright © 2019 BOTTAK. All rights reserved.
//

import UIKit
import AVFoundation


protocol CameraOutput {
    func presentCameraSession()
    func presentProcessing()
    func presentCaptureFinishedRecording(response: Camera.Record.Response)
}

final class CameraSetup: NSObject {
    
    var output: CameraSetup!
    var captureSession: AVCaptureSession!
    var dataOutput: AVCaptureVideoDataOutput!
    var progress: ((Float) -> ())!
    var captureDevice : AVCaptureDevice!
    
    
    fileprivate let totalFrame: Int = 125
    fileprivate var recordStart: Bool = true
    fileprivate var buffers = [CVImageBuffer]()
    fileprivate var converter: VideoBuilding!
    
    
    // Function to prepare the start of the session
    func prepareSession() {
        
        /// 1
        captureSession = AVCaptureSession()
        
        ///2
        let input = try? AVCaptureDeviceInput(device: connectedDevice())
        if captureSession.canAddInput(input!) {
            captureSession.addInput(input!)
        }
        
        ///3
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        captureSession.startRunning()
        
        
        ///4
        dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [
            String(kCVPixelBufferPixelFormatTypeKey) : Int(kCVPixelFormatType_420YpCbCr8PlanarFullRange)
        ]
        
        ///5
        captureSession.commitConfiguration()
        
        ///6
        let queue: DispatchQueue = DispatchQueue(label: "VideoDataOutput")
        dataOutput.setSampleBufferDelegate(self, queue: queue)
        dataOutput.connection(with: AVMediaType.video)?.videoOrientation = .portrait
        
        //output.presentCaptureSession()
    }
    
    func startRecord(){
        recordStart = true
    }
    
    
    fileprivate func connectedDevice() -> AVCaptureDevice! {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) in
                if granted {
                    print("Готова")
                    self.setUpAVCapture()
                }
                else {
                    print("Не готова")
                }
            })
        } else {
            self.setUpAVCapture()
        }
        return nil
    }
    
    func setUpAVCapture() {
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        guard let device = AVCaptureDevice
            .default(AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                     for: .video,
                     position: AVCaptureDevice.Position.back) else {
                        return
        }
        captureDevice = device

    }
    
  
    
    fileprivate func saveToCameraRoll(url: URL?, callback: @escaping (_ error: Error?) -> ()) {
        guard let url = url else { callback(nil); return }
        PhotoAlbum.shared.save(url) { (success, error) in
            callback(error)
        }
    }
}
    
    



extension CameraSetup: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        /// 1
        guard let cvBuf = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        /// 2
        if captureOutput is AVCaptureVideoDataOutput, recordStart {
            /// 3
            let copiedCvBuf = cvBuf.deepcopy()
            
            buffers.append(copiedCvBuf)
            progress?(Float(buffers.count) / Float(totalFrame))
            
            /// 4
            if buffers.count >= totalFrame {
                recordStart = false
//                merge()
            }
        }
    }
}
