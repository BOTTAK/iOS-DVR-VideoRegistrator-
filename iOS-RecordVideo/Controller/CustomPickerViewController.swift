////
////  CustomPickerViewController.swift
////  iOS-RecordVideo
////
////  Created by Владимир Королев on 21/07/2019.
////  Copyright © 2019 VladimirBrejcha. All rights reserved.
////
//
//import UIKit
//import AVFoundation
//import MediaWatermark
//

//
//class CustomPickerViewController: UIImagePickerController {
//
//    var swipeEnded = false
//    var swipedTo: SwipeSide = .none
//    let locationManager = MetaDataManager()
//
//    let setting = UIHelper.storyboard.instantiateViewController(withIdentifier: SettingsViewController.self) as! SettingsViewController
//
//    var firstTimeCapture = true
//    let longitudeSetting = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
//    let latitudeSetting = UILabel(frame: CGRect(x: 0, y: 50, width: 300, height: 50))
//    let speedSetting = UILabel(frame: CGRect(x: 0, y: 100, width: 300, height: 50))
//    let dateSetting = UILabel(frame: CGRect(x: 0, y: 150, width: 100, height: 50))
//
//    var swipeLeftRecognizer: UISwipeGestureRecognizer!
//    var swipeRightRecognizer: UISwipeGestureRecognizer!
//    var swipeDownRecognizer: UISwipeGestureRecognizer!
//    var longPressRecognizer: CustomLongPress!
//    var longitudeAddMeta: String = ""
//    var latitudeAddMeta: String = ""
//    var speedAddMeta: String = ""
//    var dateAddMeta: String = ""
//
//    var toSave = false
//
//    var notificationLabel = SwipeNotificationLabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//    var timerNotificationLabel = SwipeNotificationLabel(frame: CGRect(x: 15, y: 15, width: 100, height: 100))
//    let videoManager = VideoManager()
//    open var maximumVideoDuration = 120.0
//    open var fullVideoDuration = 16.0 // expected video file duration after montage in seconds
//
//    // MARK: LifeCycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        addRecognizers()
//        setupAndAddSubviews()
//        delegate = self
//        setting.delegate = self
//        locationManager.delegate = self
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        if firstTimeCapture {
//            startVideoCapture()
//            locationManager.getGPSFromVideo()
//        }
//    }
//
//    // MARK: View setup
//    fileprivate func addRecognizers() {
//        swipeLeftRecognizer = createGesture(target: self, action: #selector(swipeLeft), direction: .left)
//        swipeRightRecognizer = createGesture(target: self, action: #selector(swipeRight), direction: .right)
//        swipeDownRecognizer = createGesture(target: self, action: #selector(swipeDown), direction: .down)
////        longPressRecognizer = CustomLongPress(target: self, action: #selector(longPress), controller: self)
//    }
//
//    fileprivate func createGesture(target: Any?, action: Selector?, direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
//        let gesture = UISwipeGestureRecognizer(target: target, action: action)
//        gesture.direction = direction
//        gesture.delegate = self
//        view.addGestureRecognizer(gesture)
//        return gesture
//    }
//
//    fileprivate func setupAndAddSubviews() {
//        notificationLabel.center = view.center
//        view.addSubview(notificationLabel)
//        view.addSubview(timerNotificationLabel)
//        view.addSubview(settingsButton)
//        latitudeLabel()
//        longitudeLabel()
//        speedLabel()
//        dateLabel()
//    }
//
//    // MARK: Settings button setup
//    var settingsButton: UIButton {
//        let button = UIButton(frame: CGRect(x: 0, y: view.frame.height - 50,
//                                            width: view.frame.width, height: 50))
//        button.center.x = view.center.x
//        button.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4040768046)
//        button.setTitleColor(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), for: .highlighted)
//        button.setTitle("Settings", for: .normal)
//        button.addTarget(self, action: #selector(settingsButtonTouch(sender:)), for: .touchUpInside)
//        return button
////    }
////
////    @objc func settingsButtonTouch(sender: UIButton) {
////        toSave = false
////        stopVideoCapture()
////        let settingsController = setting
////        present(settingsController, animated: true, completion: nil)
////    }
////
////
////    //MARK: Setting label setup
////
////    func longitudeLabel() {
////        longitudeSetting.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4040768046)
////        longitudeSetting.textColor = #colorLiteral(red: 0.9607843137, green: 0.1921568627, blue: 0.1490196078, alpha: 1)
////        longitudeSetting.highlightedTextColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
////        longitudeSetting.text = "Latitude"
////        longitudeSetting.textAlignment = .center
////        longitudeSetting.text = longitudeAddMeta
////
////        view.addSubview(longitudeSetting)
////    }
////
////    func latitudeLabel() {
////        latitudeSetting.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4040768046)
////        latitudeSetting.textColor = #colorLiteral(red: 0.9607843137, green: 0.1921568627, blue: 0.1490196078, alpha: 1)
////        latitudeSetting.highlightedTextColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
////        latitudeSetting.text = "Latitude"
////        latitudeSetting.textAlignment = .center
////        latitudeSetting.text = latitudeAddMeta
////
////        view.addSubview(latitudeSetting)
////    }
////
////    func speedLabel() {
////        speedSetting.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4040768046)
////        speedSetting.textColor = #colorLiteral(red: 0.9607843137, green: 0.1921568627, blue: 0.1490196078, alpha: 1)
////        speedSetting.highlightedTextColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
////        speedSetting.text = "Latitude"
////        speedSetting.textAlignment = .center
////        speedSetting.text = speedAddMeta
////
////        view.addSubview(speedSetting)
////
////    }
////
////    func dateLabel() {
////        dateSetting.center.x = view.center.x
////        dateSetting.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4040768046)
////        dateSetting.textColor = #colorLiteral(red: 0.9607843137, green: 0.1921568627, blue: 0.1490196078, alpha: 1)
////        dateSetting.highlightedTextColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
////        dateSetting.text = "Date"
////        dateSetting.textAlignment = .center
//////        view.addSubview(dateSetting)
////
////    }
////
////
////    // MARK: Swipe handling
////    @objc func longPress() {
////        if longPressRecognizer.state == .changed {
////            return
////        }
////        if longPressRecognizer.state == .ended {
////            return
////        }
////        notificationLabel.changeTextAndAnimate(text: "Long press")
////    }
////    // Left
////    @objc func swipeLeft() {
////        notificationLabel.changeTextAndAnimate(text: "Left")
////        swipeEnded = true
////        swipedTo = .left
////    }
////
////    // Right
////    @objc func swipeRight() {
////        notificationLabel.changeTextAndAnimate(text: "Right")
////        swipeEnded = true
////        swipedTo = .right
////    }
////
////    @objc func swipeRightTimerAction() {
////        stopCaptureAndTrim()
////    }
////
////    // Down
////    @objc func swipeDown() {
////        notificationLabel.changeTextAndAnimate(text: "Down")
////        print("down - \(swipeDownRecognizer.state)")
////        swipeEnded = true
////        swipedTo = .down
////    }
////
////    func stopCaptureAndTrim() {
////        view.isUserInteractionEnabled = true
////        toSave = true
////        stopVideoCapture()
////    }
////
////}
////extension CustomPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
////    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
////        if toSave {
////
////            guard let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
////                UIHelper.showError(errorMessage: "Error parsing info for an URL", controller: self)
////                return
////            }
////
////
////            videoManager.trimVideo(sourceURL: videoURL, duration: fullVideoDuration, metaData: [""]) { result in
////                switch (result) {
////                case let .failure(error):
////                    UIHelper.showError(errorMessage: "Error creating URL - \(error.localizedDescription)", controller: self)
////                case let .success(video):
////
////                    if let item = MediaItem(url: video) {
////                        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 35) ]
////                        DispatchQueue.main.async {
////
////                            let lattitudeattrStr = NSAttributedString(string: self.latitudeSetting.text!, attributes: attributes)
////                            let longtitudeattrStr = NSAttributedString(string: self.longitudeSetting.text!, attributes: attributes)
////                            let speedattrStr = NSAttributedString(string: self.speedSetting.text!, attributes: attributes)
////
////                            let firstElement = MediaElement(text: lattitudeattrStr)
////                            firstElement.frame = CGRect(x: 30, y: 30, width: self.view.frame.width, height: 50)
////
////                            let secondElement = MediaElement(text: longtitudeattrStr)
////                            secondElement.frame = CGRect(x: 30, y: 80, width: self.view.frame.width, height: 50)
////
////                            let thirdElement = MediaElement(text: speedattrStr)
////                            thirdElement.frame = CGRect(x: 30, y: 120, width: self.view.frame.width, height: 50)
////
////                            item.add(elements: [firstElement, secondElement, thirdElement])
////
////                            let mediaProcessor = MediaProcessor()
////                            mediaProcessor.processElements(item: item) { [weak self] (result, error) in
////
////                                UISaveVideoAtPathToSavedPhotosAlbum(result.processedUrl!.path,
////                                                                    self,
////                                                                    #selector(self!.video(_:didFinishSavingWithError:contextInfo:)),
////                                                                    nil)
////                            }
////                        }
////
////
////                    }
////                }
////            }
////            startVideoCapture()
////        }
//    }
//
//    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
//
//        let (title, message) = error == nil
//            ? ("Success", "Video saved!")
//            : (nil, error!.localizedDescription)
//
//        UIHelper.showError(errorMessage: message, customTitle: title, action: nil, controller: self)
//    }
//}
//import MobileCoreServices
//extension CustomPickerViewController: SettingsDelegate {
//    func settingsDidChange(_ settingPickerQuility: UIImagePickerController.QualityType, _ settingPickerDuration: TimeInterval, _ settingMicrophone: String) {
//        fullVideoDuration = settingPickerDuration
//        videoQuality = settingPickerQuility
////        mediaTypes = [settingMicrophone]
//        startVideoCapture()
//    }
//
//
//}
//
//extension CustomPickerViewController: LongPressDelegate {
//    func gestureDidEnd() {
//        timerNotificationLabel.changeTextAndAnimate(text: "Stop")
//        switch swipedTo {
//        case .left:
//            stopCaptureAndTrim()
//        case .right:
//            Timer.scheduledTimer(withTimeInterval: 16, repeats: false) { (timer) in
//                self.stopCaptureAndTrim()
//            }
//            view.isUserInteractionEnabled = false
//        case .down:
//            Timer.scheduledTimer(withTimeInterval: 8, repeats: false) { (timer) in
//                self.stopCaptureAndTrim()
//            }
//            view.isUserInteractionEnabled = false
//        case .none:
//            print("unexpectred behavior")
//        }
//    }
//
//    func timerDidTick(_ time: Int) {
//        if time > 0 {
//            timerNotificationLabel.changeTextAndAnimate(text: "+\(time)")
//            fullVideoDuration += 10.0
//        }
//    }
//}
//
//extension CustomPickerViewController: UIGestureRecognizerDelegate {
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//}
//
//import CoreLocation
//extension CustomPickerViewController: MetaDataDelegate {
//    func metadataDidUpdate(_ getGPSFromVideo:  CLLocation) {
//        longitudeSetting.text = String((getGPSFromVideo.coordinate.longitude))
//        latitudeSetting.text = String((getGPSFromVideo.coordinate.latitude))
//        speedSetting.text = String((getGPSFromVideo.speed))
//    }
//
//
//}
