//
//  VideoCapturingPickerController.swift
//  iOS-RecordVideo
//
//  Created by Владимир Королев on 19/08/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit
import AVFoundation
import MediaWatermark
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
    // Left
    private var swipeLeftRecognizer: UISwipeGestureRecognizer!
    @objc func swipeLeft() {
        notificationLabel.changeTextAndAnimate(text: "Left")
        swipeEnded = true
        swipeSide = .left
    }
    // Right
    private var swipeRightRecognizer: UISwipeGestureRecognizer!
    @objc func swipeRight() {
        notificationLabel.changeTextAndAnimate(text: "Right")
        swipeEnded = true
        swipeSide = .right
    }
    // Down
    private var swipeDownRecognizer: UISwipeGestureRecognizer!
    @objc func swipeDown() {
        notificationLabel.changeTextAndAnimate(text: "Down")
        swipeEnded = true
        swipeSide = .down
    }
    // Long press
    private var longPressRecognizer: CustomLongPress!
    @objc func longPress() {
        if longPressRecognizer.state == .changed || longPressRecognizer.state == .ended {
            return
        } else {
            notificationLabel.changeTextAndAnimate(text: "Long press")
        }
    }
    // LongPressDelegate
    func gestureDidEnd() {
        timerNotificationLabel.changeTextAndAnimate(text: "Stop")
        switch swipeSide {
        case .left:
            infoLabel.changeTextAndAnimate(text: "Please wait")
            infoLabel.showTimer(seconds: 3)
            view.isUserInteractionEnabled = false
            self.stopCaptureAndTrim()
        case .right:
            view.isUserInteractionEnabled = false
            self.infoLabel.changeTextAndAnimate(text: "Please wait")
            self.infoLabel.showTimer(seconds: Int(self.currentDuration))
            Timer.scheduledTimer(withTimeInterval: currentDuration, repeats: false) { (timer) in
                self.stopCaptureAndTrim()
            }
        case .down:
            view.isUserInteractionEnabled = false
            self.infoLabel.changeTextAndAnimate(text: "Please wait")
            self.infoLabel.showTimer(seconds: Int(self.currentDuration / 2))
            Timer.scheduledTimer(withTimeInterval: currentDuration / 2, repeats: false) { (timer) in
                self.stopCaptureAndTrim()
            }
        case .none:
            return
        }
    }
    func timerDidTick(_ time: Int) {
        if time > 0 && time < Int(maximumDuration - currentDuration) {
            notificationLabel.changeTextAndAnimate(text: "+\(time)")
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
    private var notificationLabel = SwipeNotificationLabel()
    private var timerNotificationLabel = SwipeNotificationLabel()
    private var infoLabel = SwipeNotificationLabel()
    // Setup
    fileprivate func addLabels() {
        longitudeLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        view.addSubview(longitudeLabel)
        latitudeLabel.frame = CGRect(x: 0, y: 50, width: view.frame.width, height: 50)
        view.addSubview(latitudeLabel)
        speedLabel.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: 50)
        view.addSubview(speedLabel)
        dateLabel.frame = CGRect(x: 0, y: 150, width: view.frame.width, height: 50)
        view.addSubview(dateLabel)
        notificationLabel.frame = CGRect(x: 0, y: 200, width: view.frame.width, height: 50)
        view.addSubview(notificationLabel)
        timerNotificationLabel.frame = CGRect(x: 0, y: 250, width: view.frame.width, height: 50)
        view.addSubview(timerNotificationLabel)
        infoLabel.frame = CGRect(x: 0, y: 300, width: view.frame.width, height: 50)
        view.addSubview(infoLabel)
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
        infoLabel.changeTextAndAnimate(text: "Creating video")
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
            
            videoManager.trimVideo(sourceURL: videoURL, duration: currentDuration,
                                   metaData: [latitudeLabel.metadata, longitudeLabel.metadata, speedLabel.metadata, dateLabel.metadata]) { result in
                                    switch result {
                                    case let .success(video):
                                        if let item = MediaItem(url: video) {
                                            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                                              NSAttributedString.Key.font: UIFont.systemFont(ofSize: 35)]
                                            DispatchQueue.main.async {
                                                let lattitudeattrStr = NSAttributedString(string: self.latitudeLabel.metadata, attributes: attributes)
                                                let longtitudeattrStr = NSAttributedString(string: self.longitudeLabel.metadata, attributes: attributes)
                                                let speedattrStr = NSAttributedString(string: self.speedLabel.metadata, attributes: attributes)
                                                let dateatrStr = NSAttributedString(string: self.dateLabel.metadata, attributes: attributes)
                                                
                                                let firstElement = MediaElement(text: lattitudeattrStr)
                                                firstElement.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
                                                
                                                let secondElement = MediaElement(text: longtitudeattrStr)
                                                secondElement.frame = CGRect(x: 0, y: 50, width: self.view.frame.width, height: 50)
                                                
                                                let thirdElement = MediaElement(text: speedattrStr)
                                                thirdElement.frame = CGRect(x: 0, y: 100, width: self.view.frame.width, height: 50)
                                                
                                                let forthElement = MediaElement(text: dateatrStr)
                                                thirdElement.frame = CGRect(x: 0, y: 100, width: self.view.frame.width, height: 50)
                                                
                                                item.add(elements: [firstElement, secondElement, thirdElement, forthElement])
                                                
                                                let mediaProcessor = MediaProcessor()
                                                mediaProcessor.processElements(item: item) { [weak self] (result, error) in
                                                    if error != nil {
                                                        UIHelper.showError(errorMessage: "Error creating metadata - \(error!.localizedDescription)", controller: self!)
                                                    } else {
                                                        UISaveVideoAtPathToSavedPhotosAlbum(result.processedUrl!.path,
                                                                                            self,
                                                                                            #selector(self!.video(_:didFinishSavingWithError:contextInfo:)),
                                                                                            nil)
                                                    }
                                                }
                                            }
                                        }
                                    case let .failure(error):
                                        UIHelper.showError(errorMessage: "Error creating video - \(error.localizedDescription)", controller: self)
                                    }
            }
            startVideoCapture()
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
        }
        locationManager.getGPSFromVideo()
    }
}
