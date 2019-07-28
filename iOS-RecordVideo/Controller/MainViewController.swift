//
//  MainViewController.swift
//  iOS-RecordVideo
//
//  Created by Владимир Королев on 20/07/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

final class MainViewController: UIViewController {
    
    let cameraMediaType = AVMediaType.video
    let imagePicker = CustomPickerViewController()
    var permissionsGranted = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkPermissions()
    }
    
    func checkPermissions() {
        if permissionsGranted {
            setupImagePicker()
        } else {
            checkRecordingPermissions()
        }
    }
    
    private func checkRecordingPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: cameraMediaType) {
        case .authorized:
            checkMicPermissions()
        case .notDetermined, .restricted, .denied:
            AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
                if granted {
                    self.checkMicPermissions()
                } else {
                    let action = UIAlertAction(title: "Settings", style: .default, handler: { action in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        self.checkRecordingPermissions()
                    })
                    UIHelper.showError(error: "Camera access is absolutely necessary to use this app",
                                       action: action,
                                       controller: self)
                }
            }
        @unknown default:
            fatalError("Unexpected case")
        }
    }
    
    private func checkMicPermissions() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            checkSourcePermissions()
        case .undetermined, .denied:
            AVAudioSession.sharedInstance().requestRecordPermission{ granted in
                if granted {
                    self.checkSourcePermissions()
                } else {
                    let action = UIAlertAction(title: "Settings", style: .default, handler: { action in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        self.checkMicPermissions()
                    })
                    UIHelper.showError(error: "Mic access is absolutely necessary to use this app",
                                       action: action,
                                       controller: self)
                }
            }
        @unknown default:
            fatalError("Unexpected case")
        }
    }
    
    private func checkSourcePermissions() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            permissionsGranted = true
            checkPermissions()
        } else {
            permissionsGranted = false
            UIHelper.showError(error: "Camera source is not available", controller: self)
        }
    }
    
    private func setupImagePicker() {
        imagePicker.sourceType = .camera
        imagePicker.cameraDevice = .rear
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        imagePicker.cameraCaptureMode = .video
        imagePicker.cameraFlashMode = .off
        imagePicker.showsCameraControls = false
        present(imagePicker, animated: false)
    }
}
