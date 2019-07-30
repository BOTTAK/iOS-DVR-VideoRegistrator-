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

protocol SettingFromCustomView: class {
    func settingFromCustomViewController(_ settingPickerQuility: UIImagePickerController.QualityType, _ settingPickerDuration: TimeInterval,_ settingMicrophone: String)
    
}

class SettingViewController: UIViewController {
    
    
    //MARK: Outlets
    
    var settingPickerQuility: UIImagePickerController.QualityType = .typeMedium
    var settingPickerDuration:  TimeInterval = 20.0
    var settingMicrophone: String = ""
    var videoAndImageReview = UIImagePickerController()
    var videoURL: URL?
    weak var delegate: CustomPickerViewController?
    
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
        delegate?.settingFromCustomViewController(settingPickerQuility, settingPickerDuration, settingMicrophone)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func videoQualitySegmented(_ sender: UISegmentedControl) {
        if videoQuialitySegment.selectedSegmentIndex == 0 {
            settingPickerQuility = .typeLow
        } else {
            if videoQuialitySegment.selectedSegmentIndex == 1 {
                settingPickerQuility = .typeMedium
            } else {
                if videoQuialitySegment.selectedSegmentIndex == 2 {
                    settingPickerQuility = .typeHigh
                }
            }
        }
        
        
    }
    
    
    
    @IBAction func videoDurationSegmented(_ sender: UISegmentedControl) {
        if videoDurationSegment.selectedSegmentIndex == 0 {
            settingPickerDuration = 20.0
        } else {
            if videoDurationSegment.selectedSegmentIndex == 1 {
                settingPickerDuration = 30.0
            } else {
                if videoDurationSegment.selectedSegmentIndex == 2{
                    settingPickerDuration = 45.0
                } else {
                    if videoDurationSegment.selectedSegmentIndex == 3 {
                        settingPickerDuration = 60.0
                    } else {
                        if videoDurationSegment.selectedSegmentIndex == 4 {
                            settingPickerDuration = 90.0
                        } else {
                            if videoDurationSegment.selectedSegmentIndex == 5 {
                                settingPickerDuration = 120.0
                            }
                        }
                    }
                }
            }
        }
        
    }
    @IBAction func microphoneSegmented(_ sender: UISegmentedControl) {
        if microphoneSegment.selectedSegmentIndex == 0 {
            settingMicrophone = kUTTypeMovie as String
        } else {
            if microphoneSegment.selectedSegmentIndex == 1 {
                settingMicrophone = kUTTypeVideo as String
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
