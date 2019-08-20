//
//  VideoCapturingPickerController.swift
//  iOS-RecordVideo
//
//  Created by Владимир Королев on 19/08/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

extension UIGestureRecognizer {
    class func createSwipeGesture(target: UIViewController, action: Selector, direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
        let gesture = UISwipeGestureRecognizer(target: target, action: action)
        gesture.direction = direction
        gesture.delegate = target as? UIGestureRecognizerDelegate
        target.view.addGestureRecognizer(gesture)
        return gesture
    }
}

// MARK: Controller
class VideoCapturingPickerController: UIImagePickerController, UIGestureRecognizerDelegate, LongPressDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SettingsDelegate, MetaDataDelegate {
    
    // MARK: Gesture recognizers
    enum SwipeSide {
        case left
        case right
        case down
        case none
    }
    // Left
    private var swipeLeftRecognizer: UISwipeGestureRecognizer!
    @objc func swipeLeft() {
        mainInfoLabel.changeTextAndAnimate(text: "Left")
        swipeEnded = true
        swipeSide = .left
    }
    // Right
    private var swipeRightRecognizer: UISwipeGestureRecognizer!
    @objc func swipeRight() {
        mainInfoLabel.changeTextAndAnimate(text: "Right")
        swipeEnded = true
        swipeSide = .right
    }
    // Down
    private var swipeDownRecognizer: UISwipeGestureRecognizer!
    @objc func swipeDown() {
        mainInfoLabel.changeTextAndAnimate(text: "Down")
        swipeEnded = true
        swipeSide = .down
    }
    // Long press
    private var longPressRecognizer: CustomLongPress!
    @objc func longPress() {
        if longPressRecognizer.state == .changed || longPressRecognizer.state == .ended {
            return
        } else {
            mainInfoLabel.changeTextAndAnimate(text: "Long press")
        }
    }
    // LongPressDelegate
    func gestureDidEnd() {
        recordingWaitingTimerLabel.changeTextAndAnimate(text: "Stop")
        switch swipeSide {
        case .left:
            recordingInfoLabel.changeTextAndAnimate(text: "Please wait")
            recordingWaitingTimerLabel.showTimer(seconds: 3)
            view.isUserInteractionEnabled = false
            self.stopCaptureAndTrim()
        case .right:
            view.isUserInteractionEnabled = false
            recordingInfoLabel.changeTextAndAnimate(text: "Please wait")
            recordingWaitingTimerLabel.showTimer(seconds: Int(currentDuration))
            Timer.scheduledTimer(withTimeInterval: currentDuration, repeats: false) { (timer) in
                self.stopCaptureAndTrim()
            }
        case .down:
            view.isUserInteractionEnabled = false
            recordingInfoLabel.changeTextAndAnimate(text: "Please wait")
            recordingWaitingTimerLabel.showTimer(seconds: Int(self.currentDuration / 2))
            Timer.scheduledTimer(withTimeInterval: currentDuration / 2, repeats: false) { (timer) in
                self.stopCaptureAndTrim()
            }
        case .none:
            return
        }
    }
    func timerDidTick(_ time: Int) {
        if time > 0 && time < Int(maximumDuration - currentDuration) {
            mainInfoLabel.changeTextAndAnimate(text: "+\(time)")
            currentDuration += 10.0
        } else {
            print("timer wrongtime")
        }
    }
    // Setup
    fileprivate func addRecognizers() {
        swipeLeftRecognizer = UIGestureRecognizer.createSwipeGesture(target: self, action: #selector(swipeLeft), direction: .left)
        swipeRightRecognizer = UIGestureRecognizer.createSwipeGesture(target: self, action: #selector(swipeRight), direction: .right)
        swipeDownRecognizer = UIGestureRecognizer.createSwipeGesture(target: self, action: #selector(swipeDown), direction: .down)
        longPressRecognizer = CustomLongPress(target: self, action: #selector(longPress), controller: self)
    }
    // UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    // State
    var swipeEnded = false
    var swipeSide = SwipeSide.none
    
    // MARK: Labels && Buttons
    private let longitudeLabel = LabelWithMetadata()
    private let latitudeLabel = LabelWithMetadata()
    private let speedLabel = LabelWithMetadata()
    private let dateLabel = LabelWithMetadata()
    private var mainInfoLabel = SwipeNotificationLabel()
    private var recordingWaitingTimerLabel = SwipeNotificationLabel()
    private var recordingInfoLabel = SwipeNotificationLabel()
    // Setup
    fileprivate func addLabels() {
        longitudeLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        view.addSubview(longitudeLabel)
        latitudeLabel.frame = CGRect(x: 0, y: 40, width: view.frame.width, height: 40)
        view.addSubview(latitudeLabel)
        speedLabel.frame = CGRect(x: 0, y: 80, width: view.frame.width, height: 40)
        view.addSubview(speedLabel)
        dateLabel.frame = CGRect(x: 0, y: 120, width: view.frame.width, height: 40)
        view.addSubview(dateLabel)
        mainInfoLabel.frame = CGRect(x: 0, y: 200, width: view.frame.width, height: 40)
        view.addSubview(mainInfoLabel)
        recordingWaitingTimerLabel.frame = CGRect(x: 0, y: 250, width: view.frame.width, height: 40)
        view.addSubview(recordingWaitingTimerLabel)
        recordingInfoLabel.frame = CGRect(x: 0, y: 300, width: view.frame.width, height: 40)
        view.addSubview(recordingInfoLabel)
    }
    
    // MARK: Location and metadata
    private let locationManager = MetaDataManager()
    func metadataDidUpdate(_ getGPSFromVideo: CLLocation) {
        longitudeLabel.metadata = getGPSFromVideo.coordinate.longitude.description
        latitudeLabel.metadata = getGPSFromVideo.coordinate.latitude.description
        speedLabel.metadata = getGPSFromVideo.speed.description
        dateLabel.metadata = getGPSFromVideo.timestamp.description
    }
    
    // MARK: Video
    private let videoManager = VideoManager()
    open var maximumDuration = 120.0
    open var currentDuration = 16.0
    private var firstTimeCapture = true
    private func stopCaptureAndTrim() {
        recordingInfoLabel.changeTextAndAnimate(text: "Creating video")
        view.isUserInteractionEnabled = true
        toSave = true
        
        stopVideoCapture()
    }
    
    // MARK: Saving
    private var toSave = false
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        view.isUserInteractionEnabled = true
        if toSave {
            guard let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
                UIHelper.showError(errorMessage: "Error parsing info for an URL", controller: self)
                return
            }
            locationManager.getGPSFromVideo()
            
            videoManager.trimVideo(sourceURL: videoURL, duration: currentDuration,
                                   location: locationManager.generateMetadata(), labels: [latitudeLabel.metadata, longitudeLabel.metadata, speedLabel.metadata, dateLabel.metadata], date: dateLabel.metadata) { result in
                                    switch result {
                                    case let .success(video):
                                        print(video)
                                    case let .failure(error):
                                        UIHelper.showError(errorMessage: "Error creating video - \(error.localizedDescription)", controller: self)
                                    }
            }
            startVideoCapture()
            recordingInfoLabel.text = "Recording"
            recordingInfoLabel.alpha = 1.0
        }
    }
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        let (title, message) = error == nil
            ? ("Success", "Video saved!")
            : (nil, error!.localizedDescription)
        UIHelper.showError(errorMessage: message, customTitle: title, action: nil, controller: self)
    }
    
    // MARK: Settings
    // Settings button
    private var settingsButton: UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: view.frame.height - 50,
                                            width: view.frame.width, height: 50))
        button.center.x = view.center.x
        button.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4040768046)
        button.setTitleColor(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), for: .highlighted)
        button.setTitle("Settings", for: .normal)
        button.addTarget(self, action: #selector(settingsButtonTouch(sender:)), for: .touchUpInside)
        return button
    }
    @objc func settingsButtonTouch(sender: UIButton) {
        toSave = false
        stopVideoCapture()
        let settingsController = settingsViewController
        present(settingsController, animated: true, completion: nil)
    }
    private let settingsViewController = UIHelper.storyboard.instantiateViewController(withIdentifier: SettingsViewController.self) as! SettingsViewController
    func settingsDidChange(_ settingPickerQuility: UIImagePickerController.QualityType,
                           _ settingPickerDuration: TimeInterval, _ settingMicrophone: String) {
        currentDuration = settingPickerDuration
        videoQuality = settingPickerQuility
        startVideoCapture()
        recordingInfoLabel.text = "Recording"
        recordingInfoLabel.alpha = 1.0
    }
    
    // MARK: Delegates
    fileprivate func addDelegates() {
        delegate = self
        settingsViewController.delegate = self
        locationManager.delegate = self
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addRecognizers()
        addLabels()
        view.addSubview(settingsButton)
        addDelegates()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstTimeCapture {
            startVideoCapture()
            recordingInfoLabel.text = "Recording"
            recordingInfoLabel.alpha = 1.0
        }
        locationManager.getGPSFromVideo()
    }
}