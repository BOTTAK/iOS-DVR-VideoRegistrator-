//
//  SettingViewController.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 7/22/19.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices

protocol SettingFromCustomView {
    func settingFromCustomViewController()
}

class SettingViewController: UIViewController {
    
    //MARK: Outlets
    var settingPickerQuility = UIImagePickerController()
    var settingPickerDuration = UIImagePickerController()
    var settingMicrophone =  UIImagePickerController()
    var videoAndImageReview = UIImagePickerController()
    var videoURL: URL?
    
    @IBOutlet weak var videoQualityLabel: UILabel!
    @IBOutlet weak var videoDurationLabel: UILabel!
    @IBOutlet weak var microphoneLabel: UILabel!
    @IBOutlet weak var videoUploadLabel: UILabel!
    @IBOutlet weak var videoQuialitySegment: UISegmentedControl!
    @IBOutlet weak var videoDurationSegment: UISegmentedControl!
    @IBOutlet weak var microphoneSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    //MARK: - Actions

    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func videoQualitySegmented(_ sender: UISegmentedControl) {
        if videoQuialitySegment.selectedSegmentIndex == 0 {
            settingPickerQuility.videoQuality = .typeLow
        } else {
            if videoQuialitySegment.selectedSegmentIndex == 1 {
                settingPickerQuility.videoQuality = .typeMedium
            } else {
                if videoQuialitySegment.selectedSegmentIndex == 2 {
                    settingPickerQuility.videoQuality = .typeHigh
                }
            }
        }
        
        
    }
    
    
    
    @IBAction func videoDurationSegmented(_ sender: UISegmentedControl) {
        if videoDurationSegment.selectedSegmentIndex == 0 {
            settingPickerDuration.videoMaximumDuration = TimeInterval (20.0)
        } else {
            if videoDurationSegment.selectedSegmentIndex == 1 {
                settingPickerDuration.videoMaximumDuration = TimeInterval (30.0)
            } else {
                if videoDurationSegment.selectedSegmentIndex == 2{
                    settingPickerDuration.videoMaximumDuration = TimeInterval (45.0)
                } else {
                    if videoDurationSegment.selectedSegmentIndex == 3 {
                        settingPickerDuration.videoMaximumDuration = TimeInterval (60.0)
                    } else {
                        if videoDurationSegment.selectedSegmentIndex == 4 {
                            settingPickerDuration.videoMaximumDuration = TimeInterval (90.0)
                        } else {
                            if videoDurationSegment.selectedSegmentIndex == 5 {
                                settingPickerDuration.videoMaximumDuration = TimeInterval (120.0)
                            }
                        }
                    }
                }
            }
        }
        
    }
    @IBAction func microphoneSegmented(_ sender: UISegmentedControl) {
        if microphoneSegment.selectedSegmentIndex == 0 {
            settingMicrophone = CustomPickerViewController()
            settingMicrophone.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            settingMicrophone.sourceType = .camera
            settingMicrophone.cameraFlashMode = .off
            settingMicrophone.showsCameraControls = false
            settingMicrophone.mediaTypes = [kUTTypeMovie as String]
        } else {
            if microphoneSegment.selectedSegmentIndex == 1 {
                settingMicrophone = CustomPickerViewController()
                settingMicrophone.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
                settingMicrophone.sourceType = .camera
                settingMicrophone.cameraFlashMode = .off
                settingMicrophone.showsCameraControls = false
                settingMicrophone.mediaTypes = [kUTTypeVideo as String]
            }
        }
        
    }
    
    @IBAction func uploadButtonTapped(_ sender: Any) {
        
        videoAndImageReview.sourceType = .photoLibrary
        videoAndImageReview.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        videoAndImageReview.mediaTypes = ["public.movie"]
        present(videoAndImageReview, animated: true, completion: nil)
        
//        ApiManager.instance.uploadVideoToServer { (getUploadVideoToServer) in
//
//        }
    }
    
    func videoAndImageReview(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        videoURL = info[.mediaURL] as? URL
        print("videoURL:\(String(describing: videoURL))")
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
