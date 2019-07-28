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
import CoreLocation

final class MainViewController: UIViewController {
    
    let locatioManager = CLLocationManager()
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
                    UIHelper.showError(errorMessage: "Camera access is absolutely necessary to use this app",
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
            checkLocationPermissons()
        case .undetermined, .denied:
            AVAudioSession.sharedInstance().requestRecordPermission{ granted in
                if granted {
                    self.checkLocationPermissons()
                } else {
                    let action = UIAlertAction(title: "Settings", style: .default, handler: { action in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        self.checkMicPermissions()
                    })
                    UIHelper.showError(errorMessage: "Mic access is absolutely necessary to use this app",
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
            UIHelper.showError(errorMessage: "Camera source is not available", controller: self)
        }
    }
    
    private func checkLocationPermissons() {
        
        
        locatioManager.requestAlwaysAuthorization()
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locatioManager.requestAlwaysAuthorization()
        case .denied, .restricted:
            let action = UIAlertAction(title: "Settings", style: .default, handler: { action in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                self.checkLocationPermissons()
            })
            UIHelper.showError(errorMessage: "Location access is absolutely necessary to use this app",
                               action: action,
                               controller: self)
        case .authorizedAlways, .authorizedWhenInUse:
            checkSourcePermissions()
        @unknown default:
            fatalError()
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
