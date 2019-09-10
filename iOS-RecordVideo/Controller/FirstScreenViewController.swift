//
//  ViewController.swift
//  HelloScreen
//
//  Created by Roma on 9/4/19.
//  Copyright © 2019 Roma. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import ObjectiveC
import CoreLocation


class FirstScreenViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    //MARK: - Properties
    var avPlayerViewController = AVPlayerViewController()
    var player: AVPlayer?
    let locationManager = CLLocationManager()
    var recordingSession = AVAudioSession()
    var audioRecorder = AVAudioRecorder()
    
    //MARK: - Outlets
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var recordVideoButton:UIButton!
    @IBOutlet weak var recordAudioButton:UIButton!
    @IBOutlet weak var navigationSetUpButtonOutlet:UIButton!
    @IBOutlet weak var playFirstInstructionButton:UIButton!
    @IBOutlet weak var playSecondInstructionButton:UIButton!
    @IBOutlet weak var firstStepCompletedImage: UIImageView!
    @IBOutlet weak var secondVideoView: UIView!
    @IBOutlet weak var secondStepCompletedImage: UIImageView!
    
    //MARK: - Actions
    @IBAction func recordVideoButtonTapped(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    @IBAction func recordAudioButtonTapped(_ sender: Any) {
        
    }
    
    
    @IBAction func playFirstInstructionButtonTapped(_ sender: UIButton) {
        
        self.videoView.isHidden = false
        self.playFirstInstructionButton.isHidden = true
        
        playFirstInstructionVideo()
        
        
    }
    @IBAction func playSecondInstructionButton(_ sender: UIButton) {
        self.videoView.isHidden = false
        self.playSecondInstructionButton.isHidden = true
        
        playSecondInstructionVideo()
    }
    @IBAction func navigationSetUpButtonTapped(_ sender: UIButton) {
        // 1
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        // 1
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return
            
        // 2
        case .denied, .restricted:
            let alert = UIAlertController(title: "Location Services disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
            return
        case .authorizedAlways, .authorizedWhenInUse:
            break
            
        }
        
        // 4
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.videoView.isHidden = true
        self.recordVideoButton.isHidden = true
        self.recordAudioButton.isHidden = true
        self.navigationSetUpButtonOutlet.isHidden = true
        self.firstStepCompletedImage.isHidden = true
        self.secondStepCompletedImage.isHidden = true
        self.playSecondInstructionButton.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    func playFirstInstructionVideo(){
        let path = Bundle.main.path(forResource: "someVid", ofType: ".mp4")
        player = AVPlayer(url: URL(fileURLWithPath: path!))
        player!.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.videoView.frame
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.videoView.layer.insertSublayer(playerLayer, at: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(playerFirstItemDidReachEnd), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
        player!.seek(to: CMTime.zero)
        player!.play()
        self.player?.isMuted = false
        
    }
    
    func playSecondInstructionVideo(){
        let path = Bundle.main.path(forResource: "secVid", ofType: ".mp4")
        player = AVPlayer(url: URL(fileURLWithPath: path!))
        player!.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.secondVideoView.frame
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.secondVideoView.layer.insertSublayer(playerLayer, at: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(playerSecondItemDidReachEnd), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
        player!.seek(to: CMTime.zero)
        player!.play()
        self.player?.isMuted = false
        
    }
    
    @objc func playerFirstItemDidReachEnd(){
        self.videoView.isHidden = true
        self.firstStepCompletedImage.isHidden = false
        self.recordAudioButton.isHidden = false
        self.recordVideoButton.isHidden = false
        self.playFirstInstructionButton.isHidden = true
        self.videoView.reloadInputViews()
        self.playSecondInstructionButton.isHidden = false
    }
    @objc func playerSecondItemDidReachEnd(){
        self.secondVideoView.isHidden = true
        self.videoView.isHidden = true
        self.firstStepCompletedImage.isHidden = false
        self.playSecondInstructionButton.isHidden = true
        self.navigationSetUpButtonOutlet.isHidden = false
        self.secondStepCompletedImage.isHidden = false
    }
}

// self.firstStepCompletedImage.isHidden = false
