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

fileprivate typealias Granted = Bool

final class MainViewController: UIViewController {
    
    let locatioManager = CLLocationManager()
    let cameraMediaType = AVMediaType.video
    let imagePicker = CustomPickerViewController()
    
    fileprivate var permissionsGranted: Granted {
        if AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
            && AVCaptureDevice.authorizationStatus(for: .video) == .authorized
            && (CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse)
            && UIImagePickerController.isSourceTypeAvailable(.camera) {
            return true
        }
        return false
    }
    
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if permissionsGranted {
            startButton.setTitle("Start", for: .normal)
        }
    }
    
    @IBAction func startTouch(_ sender: UIButton) {
        if permissionsGranted {
            setupImagePicker()
        }
        getPermissions()
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
    
    func getPermissions() {
        AVCaptureDevice.requestPermissionIfNeeded(for: .audio) {
            AVCaptureDevice.requestPermissionIfNeeded(for: .video, handler: {
                self.checkLocationPermissons {
                    self.checkSourcePermissions {
                        self.startButton.setTitle("Start", for: .normal)
                    }
                }
            })
        }
    }
    
    private func checkLocationPermissons(handler: () -> Void) {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locatioManager.requestWhenInUseAuthorization()
            handler()
        case .denied, .restricted:
            let action = UIAlertAction(title: "Settings", style: .default) { action in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                          options: [:],
                                          completionHandler: nil)
            }
            UIHelper.showError(errorMessage: "Location permissions required", action: action, controller: self)
        case .authorizedAlways:
            handler()
        case .authorizedWhenInUse:
            handler()
        @unknown default:
            fatalError()
        }
    }
    
    private func checkSourcePermissions(handler: () -> Void) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            handler()
        } else {
            UIHelper.showError(errorMessage: "Camera source is not available", controller: self)
        }
    }

}

extension AVCaptureDevice {
    class func requestPermissionIfNeeded(for type: AVMediaType, handler: @escaping () -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: type) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: type) { granted in
                DispatchQueue.main.async {
                    if granted {
                        handler()
                    }   
                }
            }
        case .restricted, .denied:
            let action = UIAlertAction(title: "Settings", style: .default) { action in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                          options: [:],
                                          completionHandler: nil)
            }
            UIHelper.showError(errorMessage: "\(type.rawValue) permissions required", action: action,
                               controller: UIApplication.shared.keyWindow!.rootViewController!)
        case .authorized:
            handler()
        default:
            handler()
        }
    }
}
