//
//  CustomPickerViewController.swift
//  iOS-RecordVideo
//
//  Created by Владимир Королев on 21/07/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit
import AVFoundation

enum SwipeSide {
    case left
    case right
    case down
    case none
}

class CustomPickerViewController: UIImagePickerController {
    
    var swipeEnded = false
    var swipedTo: SwipeSide = .none

    let setting = UIHelper.storyboard.instantiateViewController(withIdentifier: SettingViewController.self) as! SettingViewController
    
    var firstTimeCapture = true
    
    var swipeLeftRecognizer: UISwipeGestureRecognizer!
    var swipeRightRecognizer: UISwipeGestureRecognizer!
    var swipeDownRecognizer: UISwipeGestureRecognizer!
    var longPressRecognizer: CustomLongPress!
    var longitudeAddMeta: String = ""
    var latitudeAddMeta: String = ""
    var speedAddMeta: String = ""
    var dateAddMeta: String = ""
    
    
    
    
    
    var swipeLeftRecognizer: UISwipeGestureRecognizer {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        gesture.direction = .left
        return gesture
    }
    var swipeRightRecognizer: UISwipeGestureRecognizer {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        gesture.direction = .right
        return gesture
    }
    var swipeDownRecognizer: UISwipeGestureRecognizer {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
        gesture.direction = .down
        return gesture
    }
    //MARK: UIPanGestureRecognizet
    var swipePanRecognizer: UIPanGestureRecognizer {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(swipeLeft))
        
        
        let vel = gesture.velocity(in: self.view)
        if vel.x > 0 {
            // user dragged towards the right
            print("right")
        }
        else if vel.x < 0 {
            // user dragged towards the left
            print("left")
        }
        
        if vel.y > 0 {
            // user dragged towards the down
            print("down")
        }
        else if vel.y < 0 {
            // user dragged towards the up
            print("up")
        }
       return gesture
        
        //MARK: Act to UIPanGesture
        
        if gesture.state == .began {
            
        }
        if gesture.state == .ended {
            
            
        }
        
    }
    
    //MARK: UILongPressGestureRecognizer
    
    func swipeLongRecognizer() {
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.view.addGestureRecognizer(lpgr)
        
    }
    
    
    //MARK: Act to UILong
    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizer.State.ended {
            return
        }
        
        let p = gestureReconizer.location(in: self.view)

            print("Could not find index path")
        
    }
    
    var toSave = false
    
    var notificationLabel = SwipeNotificationLabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    var timerNotificationLabel = SwipeNotificationLabel(frame: CGRect(x: 15, y: 15, width: 100, height: 100))
    let videoManager = VideoManager()
    open var maximumVideoDuration = 120.0
    open var fullVideoDuration = 20.0 // expected video file duration after montage in seconds

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addRecognizers()
        setupAndAddSubviews()
        delegate = self
        setting.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if firstTimeCapture {
            startVideoCapture()
        }
    }
    
    // MARK: View setup
    fileprivate func addRecognizers() {
        swipeLeftRecognizer = createGesture(target: self, action: #selector(swipeLeft), direction: .left)
        swipeRightRecognizer = createGesture(target: self, action: #selector(swipeRight), direction: .right)
        swipeDownRecognizer = createGesture(target: self, action: #selector(swipeDown), direction: .down)
        longPressRecognizer = CustomLongPress(target: self, action: #selector(longPress), controller: self)
    }
    
    fileprivate func createGesture(target: Any?, action: Selector?, direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
        let gesture = UISwipeGestureRecognizer(target: target, action: action)
        gesture.direction = direction
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
        return gesture
    }
    
    fileprivate func setupAndAddSubviews() {
        notificationLabel.center = view.center
        view.addSubview(notificationLabel)
        view.addSubview(timerNotificationLabel)
        view.addSubview(settingsButton)
    }
    
    // MARK: Settings button setup
    var settingsButton: UIButton {
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
        let settingsController = setting
        present(settingsController, animated: true, completion: nil)
    }
    
    
    //MARK: Setting label setup
    
    func longitudeLabel() {
        let longitudeSetting = UILabel(frame: CGRect(x: 0, y: view.frame.height - 50, width: view.frame.width, height: 50))
        
        let longitudeSetting = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        longitudeSetting.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15)
        longitudeSetting.topAnchor.constraint(equalTo: view.topAnchor, constant: 15)
        longitudeSetting.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4040768046)
        longitudeSetting.textColor = #colorLiteral(red: 0.9607843137, green: 0.1921568627, blue: 0.1490196078, alpha: 1)
        longitudeSetting.highlightedTextColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        longitudeSetting.text = "Latitude"
        longitudeSetting.textAlignment = .center
        longitudeSetting.text = longitudeAddMeta
        
        
        view.addSubview(longitudeSetting)
        
    }
    
    func latitudeLabel() {
        let latitudeSetting = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        latitudeSetting.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15)
        latitudeSetting.topAnchor.constraint(equalTo: view.topAnchor, constant: 80)
        latitudeSetting.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4040768046)
        latitudeSetting.textColor = #colorLiteral(red: 0.9607843137, green: 0.1921568627, blue: 0.1490196078, alpha: 1)
        latitudeSetting.highlightedTextColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        latitudeSetting.text = "Latitude"
        latitudeSetting.textAlignment = .center
        latitudeSetting.text = latitudeAddMeta
        
        view.addSubview(latitudeSetting)
        
    }
    
    func speedLabel() {
        let speedSetting = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        speedSetting.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 15)
        speedSetting.topAnchor.constraint(equalTo: view.topAnchor, constant: 15)
        speedSetting.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4040768046)
        speedSetting.textColor = #colorLiteral(red: 0.9607843137, green: 0.1921568627, blue: 0.1490196078, alpha: 1)
        speedSetting.highlightedTextColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        speedSetting.text = "Latitude"
        speedSetting.textAlignment = .center
        speedSetting.text = speedAddMeta
        
        view.addSubview(speedSetting)
        
    }
    
    func dateLabel() {
        let dateSetting = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        dateSetting.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 15)
        dateSetting.topAnchor.constraint(equalTo: view.topAnchor, constant: 80)
        dateSetting.center.x = view.center.x
        dateSetting.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4040768046)
        dateSetting.textColor = #colorLiteral(red: 0.9607843137, green: 0.1921568627, blue: 0.1490196078, alpha: 1)
        dateSetting.highlightedTextColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        dateSetting.text = "Date"
        dateSetting.textAlignment = .center
        view.addSubview(dateSetting)
        
    }

    
    // MARK: Swipe handling
    @objc func longPress() {
        if longPressRecognizer.state == .changed {
            return
        }
        notificationLabel.changeTextAndAnimate(text: "Long press")
    }
    // Left
    @objc func swipeLeft() {
        notificationLabel.changeTextAndAnimate(text: "Left")
        print("left")
        swipeEnded = true
        swipedTo = .left
//        stopCaptureAndTrim()
    }
    
    // Right
    @objc func swipeRight() {
        notificationLabel.changeTextAndAnimate(text: "Right")
        print("right")
        swipeEnded = true
        swipedTo = .right
//        notificationLabel.showTimer(seconds: Int(fullVideoDuration))
//        Timer.scheduledTimer(timeInterval: fullVideoDuration,
//                             target: self,
//                             selector: #selector(swipeRightTimerAction),
//                             userInfo: nil, repeats: false)
//        view.isUserInteractionEnabled = false
    }
    
    @objc func swipeRightTimerAction() {
        stopCaptureAndTrim()
    }
    
    // Down
    @objc func swipeDown() {
        notificationLabel.changeTextAndAnimate(text: "Down")
        print("down - \(swipeDownRecognizer.state)")
        swipeEnded = true
        swipedTo = .down
//        notificationLabel.changeTextAndAnimate(text: "Down")
//        notificationLabel.showTimer(seconds: Int(fullVideoDuration / 2))
//        Timer.scheduledTimer(timeInterval: fullVideoDuration / 2,
//                             target: self,
//                             selector: #selector(swipeDownTimerAction),
//                             userInfo: nil, repeats: false)
//        view.isUserInteractionEnabled = false
    }
    
    @objc func swipeDownTimerAction() {
        stopCaptureAndTrim()
    }
    
    func stopCaptureAndTrim() {
        view.isUserInteractionEnabled = true
        toSave = true
        stopVideoCapture()
    }
    
}
extension CustomPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if toSave {
            
            guard let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
                UIHelper.showError(errorMessage: "Error parsing info for an URL", controller: self)
                return
            }
            
            let locationManager = MetaDataManager()
            
            videoManager.trimVideo(sourceURL: videoURL, duration: fullVideoDuration, metaData: locationManager.getGPSFromVideo()) { result in
                switch (result) {
                case let .failure(error):
                    UIHelper.showError(errorMessage: "Error creating URL - \(error.localizedDescription)", controller: self)
                case let .success((video, metadata)):
                    metadata.first?.value
                    
                    let videoPath = video.path
                    UISaveVideoAtPathToSavedPhotosAlbum(videoPath,

                                                        self,
                                                        #selector(self.video(_:didFinishSavingWithError:contextInfo:)),
                                                        nil)
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
}
import MobileCoreServices
extension CustomPickerViewController: SettingFromCustomView {
    func settingFromCustomViewController(_ settingPickerQuility: UIImagePickerController.QualityType, _ settingPickerDuration: TimeInterval, _ settingMicrophone: String) {
        fullVideoDuration = settingPickerDuration
        videoQuality = settingPickerQuility
        mediaTypes = [settingMicrophone]
        startVideoCapture()
    }
    
    
}

extension CustomPickerViewController: LongPressDelegate {
    func gestureDidEnd() {
        timerNotificationLabel.changeTextAndAnimate(text: "Stop")
    }
    
    func timerDidTick(_ time: Int) {
        timerNotificationLabel.changeTextAndAnimate(text: "+\(time)")
        fullVideoDuration += 10.0
    }
}

extension CustomPickerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

import CoreLocation
extension CustomPickerViewController: MetaDataManagerSetting {
    func metaDataManagerSetting(_ getGPSFromVideo:  CLLocation) {
        longitudeAddMeta = String((getGPSFromVideo.coordinate.longitude))
        latitudeAddMeta = String((getGPSFromVideo.coordinate.latitude))
        speedAddMeta = String((getGPSFromVideo.speed))
        
        
        
    }
    
    
}
