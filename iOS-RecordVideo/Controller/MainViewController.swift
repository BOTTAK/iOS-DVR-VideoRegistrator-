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
        imagePicker.sourceType = .camera
        imagePicker.cameraDevice = .rear
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        imagePicker.cameraCaptureMode = .video
        imagePicker.cameraFlashMode = .off
        imagePicker.showsCameraControls = false
       
        present(imagePicker, animated: false)
    }
}
