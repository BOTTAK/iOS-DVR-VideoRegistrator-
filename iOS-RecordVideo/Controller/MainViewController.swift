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
    
    var imagePicker = CustomPickerViewController()
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkSourcePermissions()
    }
    
    private func checkSourcePermissions() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("source type available")
            setupImagePicker()
        } else {
            let alert =  UIAlertController(title: "Ошибка", message: "Камера недоступна", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: UIAlertAction.Style.cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func setupImagePicker() {
        imagePicker.sourceType = .camera
        imagePicker.videoQuality = .typeHigh
        imagePicker.cameraDevice = .rear
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        imagePicker.cameraCaptureMode = .video
        
        imagePicker.cameraFlashMode = .off
        imagePicker.showsCameraControls = false
       
        present(imagePicker, animated: false)
    }
}
