//
//  VideoCapturingPickerController.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 19/08/2019.
//  Copyright © 2019 BOTTAK. All rights reserved.
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
            recordingWaitingTimerLabel.showTimer(seconds: Int(currentDuration / 2))
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
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
//    override open var shouldAutorotate: Bool {
//        return false
//    }
    
    private let longitudeLabel = LabelWithMetadata()
    private let latitudeLabel = LabelWithMetadata()
    private let speedLabel = LabelWithMetadata()
    private let dateLabel = LabelWithMetadata()
    private var mainInfoLabel = SwipeNotificationLabel()
    private var recordingWaitingTimerLabel = SwipeNotificationLabel()
    private var recordingInfoLabel = SwipeNotificationLabel()
    // Setup
    fileprivate func addLabels() {
        longitudeLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 15)
        view.addSubview(longitudeLabel)
        latitudeLabel.frame = CGRect(x: 0, y: view.frame.height / 15, width: view.frame.width, height: view.frame.height / 15)
        view.addSubview(latitudeLabel)
        speedLabel.frame = CGRect(x: 0, y: 2 * (view.frame.height / 15), width: view.frame.width, height: view.frame.height / 15)
        view.addSubview(speedLabel)
        dateLabel.frame = CGRect(x: 0, y: 3 * (view.frame.height / 15), width: view.frame.width, height: view.frame.height / 15)
        view.addSubview(dateLabel)
        mainInfoLabel.frame = CGRect(x: 0, y: 4 * (view.frame.height / 15), width: view.frame.width, height: view.frame.height / 15)
        view.addSubview(mainInfoLabel)
        recordingWaitingTimerLabel.frame = CGRect(x: 0, y: 5 * (view.frame.height / 15), width: view.frame.width, height: view.frame.height / 15)
        view.addSubview(recordingWaitingTimerLabel)
        recordingInfoLabel.frame = CGRect(x: 0, y: 6 * (view.frame.height / 15), width: view.frame.width, height: view.frame.height / 15)
        view.addSubview(recordingInfoLabel)
    }
    
    // MARK: Location and metadata
    private let locationManager = MetaDataManager()
    var storedLocationDataArray: [(CLLocation, String)] = []
    var locationTimer: Timer?
    func startLocationTimer() {
        locationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(locationTimerDidTick), userInfo: nil, repeats: true)
    }
    
    @objc func locationTimerDidTick() {
        if storedLocationDataArray.count > 300 {
            storedLocationDataArray.removeFirst()
        }
        storedLocationDataArray.append(locationManager.getLocation())
    }
    func metadataDidUpdate(_ getGPSFromVideo: CLLocation) {
        longitudeLabel.metadata = getGPSFromVideo.coordinate.longitude.description
        latitudeLabel.metadata = getGPSFromVideo.coordinate.latitude.description
        speedLabel.metadata = getGPSFromVideo.speed.description
        dateLabel.metadata = getGPSFromVideo.timestamp.description
    }
    
    // MARK: Video
    private let videoManager = VideoManager()
    open var maximumDuration = 2400.0
    open var currentDuration = 16.0
    private func stopCaptureAndTrim() {
        recordingInfoLabel.changeTextAndAnimate(text: "Creating video")
        view.isUserInteractionEnabled = true
        toSave = true
        print(currentDuration)
        stopVideoCapture()
    }
    
    //MARK: - Outlets
    
    
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
            
            let storage = GeolocationStorage()
            storage.startTime = Date(timeIntervalSinceNow: -currentDuration)
            var numberOfIterations = currentDuration
            let locationArray = storedLocationDataArray
            var continueIterating = true
             print(locationArray)
            while continueIterating {
                if numberOfIterations > 0 {
                    numberOfIterations -= 1
                    print(locationArray.count, numberOfIterations)
                   
                    storage.add(record: GeolocationStorage.Record(location: locationArray[locationArray.count - 1 - Int(numberOfIterations)].0,
                                                                  timecode: Date(timeIntervalSinceNow: -numberOfIterations)))
                } else {
                    videoManager.trimVideo(sourceURL: videoURL,
                                           duration: currentDuration,
                                           location: locationManager.generateMetadata(),
                                           labels: [latitudeLabel.metadata,  longitudeLabel.metadata, speedLabel.metadata, dateLabel.metadata],
                                           startTime: storage.startTime!,
                                           geolocationStorage: storage,
                                           date: dateLabel.metadata) { result in
                                            switch result {
                                            case let .success(video):
                                                let asset = AVURLAsset(url: video, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
                                                guard let exportSession = AVAssetExportSession(asset: asset,
                                                                                               presetName: AVAssetExportPresetPassthrough) else { fatalError() }
                                                
                                                exportSession.timeRange = self.generateRange(startTime: asset.duration.seconds - self.currentDuration,
                                                                                             endTime: asset.duration.seconds)
                                                print("duration -\(self.currentDuration)")
                                                exportSession.outputURL = FileManager.createNewFilePath(fileName: videoName)
                                                exportSession.outputFileType = AVFileType.mp4
                                                exportSession.shouldOptimizeForNetworkUse = true
                                                
                                                exportSession.exportAsynchronously(completionHandler: {() -> Void in
                                                    switch exportSession.status {
                                                    case .failed:
                                                        print(exportSession.error ?? "No error")
                                                    case .cancelled:
                                                        let error = NSError(domain: "VideoApp", code: 00, userInfo: ["Message": "Export cancelled"])
                                                        print(error.localizedDescription)
                                                    case .completed:
                                                        guard let correctURL = exportSession.outputURL
                                                            else {
                                                                print("error getting url")
                                                                return
                                                        }
                                                        UISaveVideoAtPathToSavedPhotosAlbum(correctURL.path,
                                                                                            self,
                                                                                            #selector(self.video(_:didFinishSavingWithError:contextInfo:)),
                                                                                            nil)
                                                        print("Successful! \(correctURL)")
                                                    default:
                                                        fatalError()
                                                    }
                                                })
                                            case let .failure(error):
                                                UIHelper.showError(errorMessage: "Error creating video - \(error.localizedDescription)", controller: self)
                                            }
                                            self.currentDuration = self.settingsViewController.settingPickerDuration
                    }
                    startVideoCapture()
                    recordingInfoLabel.text = "Recording"
                    recordingInfoLabel.alpha = 1.0
                    continueIterating = false
                    break
                }
            }
        }
    }
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        let (title, message) = error == nil
            ? ("Success", "Video saved!")
            : (nil, error!.localizedDescription)
        UIHelper.showError(errorMessage: message, customTitle: title, action: nil, controller: self)
    }
    
    private func generateRange(startTime: Double, endTime: Double) -> CMTimeRange {
        let defaultTimeScale: CMTimeScale = 600
        let rangeStart = CMTime(seconds: startTime, preferredTimescale: defaultTimeScale)
        let rangeEnd = CMTime(seconds: endTime, preferredTimescale: defaultTimeScale)
        return CMTimeRangeMake(start: rangeStart, duration: rangeEnd)
    }
    
    // MARK: Settings
    // Settings button
    private var settingsButton: UIButton {
        let button = UIButton(frame: CGRect(x: 0,
                                            y: view.frame.height - view.frame.height / 7,
                                            width: view.frame.width,
                                            height: (view.frame.height / 7)))
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
        
        func shouldAutorotate() -> Bool {
            return false
        }
        
//        func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//            return UIInterfaceOrientationMask.landscape
//        }
        
        
        startLocationTimer()
        view.addSubview(settingsButton)
        addDelegates()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        currentDuration = settingsViewController.settingPickerDuration
        startVideoCapture()
        recordingInfoLabel.text = "Recording"
        recordingInfoLabel.alpha = 1.0
        locationManager.getGPSFromVideo()
    }
    

    
//    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
//        return .landscapeLeft
//
//    }
    
    
    
}



