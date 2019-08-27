//
//  SettingViewController.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 7/22/19.
//  Copyright © 2019 BOTTAK. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices

protocol SettingsDelegate: class {
    func settingsDidChange(_ settingPickerQuility: UIImagePickerController.QualityType, _ settingPickerDuration: TimeInterval,_ settingMicrophone: String)
    
}

class SettingsViewController: UIViewController {
    
    
    //MARK: Outlets
    
    var settingPickerQuility: UIImagePickerController.QualityType = .typeMedium
    var settingPickerDuration:  TimeInterval = 16.0
    var settingMicrophone: String = ""
    var videoURL: URL?
    weak var delegate: SettingsDelegate?
    
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
        dismiss(animated: true, completion: nil)
        delegate?.settingsDidChange(settingPickerQuility, settingPickerDuration, settingMicrophone)
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
            settingPickerDuration = 16.0
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
    
    
    
}
