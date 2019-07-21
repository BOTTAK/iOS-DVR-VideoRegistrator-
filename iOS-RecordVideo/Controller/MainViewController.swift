//
//  MainViewController.swift
//  iOS-RecordVideo
//
//  Created by Владимир Королев on 20/07/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit
import MobileCoreServices

class MainViewController: UIViewController {
    
    var imagePicker: CustomPickerViewController!
    var timer: Timer?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkSourcePermissions()
    }
    
    private func checkSourcePermissions() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("source type available")
            setupImagePicker()
        } else {
            print("source type unavailable")
            
        }
    }
    
    private func setupImagePicker() {
        imagePicker = CustomPickerViewController()
        imagePicker.delegate = self
        imagePicker.swipeDelegate = self
        imagePicker.sourceType = .camera
        imagePicker.cameraFlashMode = .off
        imagePicker.showsCameraControls = false
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        imagePicker.videoMaximumDuration = TimeInterval(5.0)
        present(imagePicker, animated: false) {
            self.startRecording()
        }
    }
    
    private func startRecording() {
        imagePicker.startVideoCapture()
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(timerRepeat), userInfo: nil, repeats: false)
    }

    @objc func timerRepeat() {
        imagePicker.stopVideoCapture()
    }
}

extension MainViewController: CustomPickerControllerDelegate {
    func userDidSwapLeft() {
        
    }
    
    func userDidSwapRight() {
        
    }
    
    func userDidSwapDown() {
        
    }
    
    
}

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
