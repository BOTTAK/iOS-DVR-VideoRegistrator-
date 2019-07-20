//
//  CameraFrameViewController.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 6/20/19.
//  Copyright © 2019 BOTTAK. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class CameraFrameViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
    
    //MARK: - Outlets
    @IBOutlet weak var cameraPreview: UIView!
//    @IBOutlet weak var frameImageView: UIImageView!
    
    
    var videoDataOutput: AVCaptureVideoDataOutput!
    var videoDataOutputQueue: DispatchQueue!
    var previewLayer:AVCaptureVideoPreviewLayer!
    var captureDevice : AVCaptureDevice!
    let session = AVCaptureSession()
    let context = CIContext()
    var imageArray: [UIImage] = []
    var imageArray20: [[UIImage]] = [[]]
    var finalImageArray: [[UIImage]] = [[]]

    
    
    
    //MARK: - Lifecylce
    override func viewDidLoad() {
        super.viewDidLoad()
        FileManagerCreateAndSave.instance.createDirectory()
        

        // Do any additional setup after loading the view, typically from a nib.
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) in
                if granted {
                    print("granted")
                    self.setUpAVCapture()
                }
                else {
                    print("not granted")
                }
            })
        } else {
            self.setUpAVCapture()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCamera()
    }
    
    // To add the layer of your preview
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer?.frame = self.cameraPreview.layer.bounds
    }
    
    //MARK: - Actions
    @IBAction func swipeHandle(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            func captureOutputRight(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
                // do stuff here
                print("Got a frame")
                DispatchQueue.global(qos: .background).async { [unowned self] in
                    guard let uiImage = self.imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return  }
                    if self.imageArray.count < 125 {
                        self.imageArray.append(uiImage)

                    } else {
                        FileManagerCreateAndSave.instance.removeFromTempFolder()
                        for image in self.imageArray {
                            FileManagerCreateAndSave.instance.saveImageToDirectory(image)
                        }
                        VideoManager.instance.buildVideoFromImageArray(self.imageArray)
                        self.imageArray.removeAll()
                    }
                }
                
            }
        } else if sender.direction == .left {
            func captureOutputLeft(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
                // do stuff here
                print("Got a frame")
                DispatchQueue.main.async (qos: .background) { [unowned self] in
                    guard let uiImage = self.imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return  }
                    if self.imageArray.count < 125 {
                        self.imageArray.append(uiImage)

                    } else {
                       FileManagerCreateAndSave.instance.removeFromTempFolder()
                        for image in self.imageArray {
                           FileManagerCreateAndSave.instance.saveImageToDirectory(image)
                        }
                        self.imageArray.removeAll()
                    }

                }
                
            }
            
        } else if sender.direction == .up{
           
        } else if sender.direction == .down{
            func captureOutputDown(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
                // do stuff here
                print("Got a frame")
                DispatchQueue.main.async { [unowned self] in
                    guard let uiImage = self.imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return  }
                    if self.imageArray.count < 125 {
                        self.imageArray.append(uiImage)

                    } else {
                       FileManagerCreateAndSave.instance.removeFromTempFolder()
                        for image in self.imageArray {
                           FileManagerCreateAndSave.instance.saveImageToDirectory(image)
                        }
                        self.imageArray.removeAll()
                    }
 
                }
                
            }
        }
    }
    
    
    // To set the camera and its position to capture
    func setUpAVCapture() {
        session.sessionPreset = AVCaptureSession.Preset.hd1280x720
        guard let device = AVCaptureDevice
            .default(AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                     for: .video,
                     position: AVCaptureDevice.Position.back) else {
                        return
        }
        captureDevice = device
        beginSession()
    }
    
    // Function to setup the beginning of the capture session
    func beginSession(){
        var deviceInput: AVCaptureDeviceInput!
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            guard deviceInput != nil else {
                print("error: cant get deviceInput")
                return
            }
            
            if self.session.canAddInput(deviceInput){
                self.session.addInput(deviceInput)
            }
            
            videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.alwaysDiscardsLateVideoFrames=true
            videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
            videoDataOutput.setSampleBufferDelegate(self, queue:self.videoDataOutputQueue)
            
            if session.canAddOutput(self.videoDataOutput){
                session.addOutput(self.videoDataOutput)
            }
            
            videoDataOutput.connection(with: .video)?.isEnabled = true
            
            previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            
            let rootLayer :CALayer = self.cameraPreview.layer
            rootLayer.masksToBounds=true
            
            rootLayer.addSublayer(self.previewLayer)
            session.startRunning()
        } catch let error as NSError {
            deviceInput = nil
            print("error: \(error.localizedDescription)")
        }
    }
    
    // Function to capture the frames again and again
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // do stuff here
        print("Got a frame")
        DispatchQueue.main.async(qos: .default ) { [unowned self] in

            guard let uiImage = self.imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return  }
            if self.imageArray.count < 125 {
                self.imageArray.append(uiImage)
                
            } else {
                for image in self.imageArray {
                }
                self.imageArray.removeAll()
            }
            
//
//            while self.imageArray20.count < 4 {
//                if self.imageArray.count < 125 {
//                    self.imageArray.append(uiImage)
//
//                } else if self.imageArray.count == 125 {
//                    FileManagerCreateAndSave.instance.removeFromTempFolder()
//                    for image in self.imageArray {
//                       FileManagerCreateAndSave.instance.saveImageToDirectory(image)
//                    }
//                    self.imageArray.removeAll()
//                }
//            }
            
        }
        
    }
    
    
    
    
    // Function to process the buffer and return UIImage to be used
    func imageFromSampleBuffer(sampleBuffer : CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    @IBAction func openDirectory(_ sender: Any) {
  
            
//        NSIG.shared.selectFile(nil, inFileViewerRootedAtPath: "/temp/")
        
    }
    
    // To stop the session
    func stopCamera(){
        session.stopRunning()
    }
    
    
    
    
}
