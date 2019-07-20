//
//  ViewController.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 6/19/19.
//  Copyright © 2019 BOTTAK. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices
import AVFoundation
//import LFLiveKit

class RecordVideoViewController: UIViewController {
    
    // свайпы влево вправо вниз регулируют длительность сохраняемого видео 20 или 60 сек
    // вниз настройки
    
    //MARK: - Outlets
    @IBOutlet weak var recordVideoButtonDidTap: UIButton!
    
    var videoAndImageReview = UIImagePickerController()
    var videoURL: URL?
    var videoBuffer = UIImagePickerController()
    var content = CIContext()
    var frame = [UIImage]()
    private var generator: AVAssetImageGenerator!
    var timer: Timer?
    var imagePicker: UIImagePickerController!
    
    //MARK: - LifeCycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //        checkPermissions()
        checkSource()
        startRecording()
    }
    
    // MARK: UIIMAGEPICKER SETUP
    //    private func checkPermissions() {
    //        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
    //            //already authorized
    //        } else {
    //            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
    //                if granted {
    //                    //access allowed
    //                } else {
    //                    //access denied
    //                }
    //            })
    //        }
    //    }
    
    private func checkSource() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("source type available")
            setupImagePicker()
        } else {
            print("source type unavailable")
            
        }
    }
    
    private func setupImagePicker() {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.cameraFlashMode = .off
        imagePicker.showsCameraControls = false
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        imagePicker.videoMaximumDuration = TimeInterval(5.0)
        //        imagePicker.allowsEditing = true // why do we need this?
        present(imagePicker, animated: false) {
            self.startRecording()
        }
    }
    
    private func startRecording() {
        imagePicker.startVideoCapture()
        startTimer()
        print("OK")
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(timerRepeat), userInfo: nil, repeats: false)
    }
    
    @objc func timerRepeat() {
        imagePicker.stopVideoCapture()
        print("timer cycle")
    }
    
    //    func bufferTimeVideo() {
    //
    //    }
    
    //    func videoFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
    //        guard let videoBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
    //        let ciVideo = CIImage(cvPixelBuffer: videoBuffer)
    //
    //        guard let cgVideo = content.createCGImage(ciVideo, from: ciVideo.extent) else { return nil }
    //        return UIImage(cgImage: cgVideo)
    //    }
    
    
    //MARK: - Actions
    //    @IBAction func recordVideoButtonTapped(_ sender: Any) {
    //    }
    //
    
    
    
    
    //    @IBAction func playVideoButtonTapped(_ sender: Any) {
    //        videoAndImageReview.sourceType = .photoLibrary
    //        videoAndImageReview.delegate = self
    //        videoAndImageReview.mediaTypes = ["public.movie"]
    //        present(videoAndImageReview, animated: true, completion: nil)
    //    }
    
    
    //    func videoAndImageReview(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    //        videoURL = info[.mediaURL] as? URL
    //        print("videoURL:\(String(describing: videoURL))")
    //        self.dismiss(animated: true, completion: nil)
    //    }
    
}

// MARK: Picker delegate and saving data
extension RecordVideoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let mediaType = info[.mediaType] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[.mediaURL] as? URL,
            UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
            else { return }
        
        // Handle a movie capture
        UISaveVideoAtPathToSavedPhotosAlbum(url.path,
                                            self,
                                            #selector(video(_:didFinishSavingWithError:contextInfo:)),
                                            nil)
    }
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        
        let alert = error == nil
            ? UIAlertController(title: "Успешно", message: "Видео сохранено", preferredStyle: .alert)
            : UIAlertController(title: "Ошибка", message: error?.localizedDescription, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ок", style: UIAlertAction.Style.cancel, handler: { _ in
            self.startRecording()
        }))
        
        imagePicker.present(alert, animated: true, completion: nil)
    }
}



extension AVCaptureDevice {
    func setFrameSupported (frameRate: Double) {
        guard let range = activeFormat.videoSupportedFrameRateRanges.first,
            range.minFrameRate...range.maxFrameRate ~= frameRate
            else {
                print("Requested FPS is not supported by the device's activeFormat !")
                return
        }
        
        do { try lockForConfiguration()
            activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(frameRate))
            activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(frameRate))
            unlockForConfiguration()
        } catch {
            print("LockForConfiguration failed with error: \(error.localizedDescription)")
        }
    }
}
