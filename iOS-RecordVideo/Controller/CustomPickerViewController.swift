//
//  CustomPickerViewController.swift
//  iOS-RecordVideo
//
//  Created by Владимир Королев on 21/07/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit

class CustomPickerViewController: UIImagePickerController {
    
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
    
    var notificationLabel = SwipeNotificationLabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    var timer: Timer?
    
    var buffer = Buffer()
    let videoMerger = DPVideoMerger()
    
    open var bufferSize = 5 // duration of video fragments in seconds
    open var fullVideoDuration = 20 // expected video file duration after montage in seconds
    private var expectedNumberOfFragments: Int { // returns number of fragments depending on configuration
        return fullVideoDuration / bufferSize
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addRecognizers()
        setupAndAddSubviews()
        delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startRecording()
    }
    
    // MARK: View setup
    fileprivate func addRecognizers() {
        view.addGestureRecognizer(swipeLeftRecognizer)
        view.addGestureRecognizer(swipeRightRecognizer)
        view.addGestureRecognizer(swipeDownRecognizer)
    }
    
    fileprivate func setupAndAddSubviews() {
        notificationLabel.center = view.center
        view.addSubview(notificationLabel)
        let window = UIApplication.shared.keyWindow!
        window.addSubview(settingsButton)
    }
    
    // MARK: Settings button setup
    var settingsButton: UIButton {
        let button = UIButton(frame: CGRect(x: 50, y: 50, width: 100, height: 50))
        button.setTitle("Settings", for: .normal)
        button.addTarget(self, action: #selector(settingsButtonTouch(sender:)), for: .touchUpInside)
        return button
    }
    
    
    @objc func settingsButtonTouch(sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsController = storyBoard.instantiateViewController(withIdentifier: "SettingViewController")
        present(settingsController, animated: true, completion: nil)
    }
    
    // MARK: Recording
    private func startRecording() {
        startVideoCapture()
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(bufferSize), target: self, selector: #selector(timerRepeat), userInfo: nil, repeats: true)
    }
    
    @objc func timerRepeat() {
        stopVideoCapture()
    }
    
    @objc func swipeLeft() {
        notificationLabel.changeTextAndAnimate(text: "Left")
        if buffer.returnArrayElements(numberOfElements: expectedNumberOfFragments).count < expectedNumberOfFragments {
            let alert =  UIAlertController(title: "Ошибка", message: "Недостаточно данных для сохранения", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: UIAlertAction.Style.cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            videoMerger.mergeVideos(withFileURLs: buffer.returnArrayElements(numberOfElements: expectedNumberOfFragments)) { (mergedVideo, error) in
                if error != nil {
                    let errorMessage = "Could not merge videos: \(error?.localizedDescription ?? "error")"
                    let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                    self.present(alert, animated: true) {() -> Void in }
                    return
                }
                
                // Handle a movie saving
                UISaveVideoAtPathToSavedPhotosAlbum(mergedVideo!.path,
                                                    self,
                                                    #selector(self.video(_:didFinishSavingWithError:contextInfo:)),
                                                    nil)
            }
        }
    }
    
    @objc func swipeRight() {
        notificationLabel.changeTextAndAnimate(text: "Right")
        
        Timer.scheduledTimer(timeInterval: TimeInterval(expectedNumberOfFragments * 6) , target: self, selector: #selector(swipeRightTimerSelector), userInfo: nil, repeats: false)
    }
    
    @objc func swipeRightTimerSelector() {
        videoMerger.mergeVideos(withFileURLs: buffer.returnArrayElements(numberOfElements: 4)) { (mergedVideo, error) in
            if error != nil {
                let errorMessage = "Could not merge videos: \(error?.localizedDescription ?? "error")"
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                self.present(alert, animated: true) {() -> Void in }
                return
            }
            
            // Handle a movie saving
            UISaveVideoAtPathToSavedPhotosAlbum(mergedVideo!.path,
                                                self,
                                                #selector(self.video(_:didFinishSavingWithError:contextInfo:)),
                                                nil)
        }
    }
    
    
    @objc func swipeDown() {
        notificationLabel.changeTextAndAnimate(text: "Down")
        let pastURLArray: [URL] = buffer.returnArrayElements(numberOfElements: 2)
        
        Timer.scheduledTimer(timeInterval: Double(expectedNumberOfFragments) * 3, target: self, selector: #selector(swipeDownTimerSelector), userInfo: pastURLArray, repeats: false)
    }
    
    @objc func swipeDownTimerSelector(timer: Timer) {
        guard var userInfo = timer.userInfo as? [URL] else {
            let alert =  UIAlertController(title: "Ошибка", message: "Данные не обнаружены", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: UIAlertAction.Style.cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        guard userInfo.count == 2 else {
            print(userInfo.count)
            let alert =  UIAlertController(title: "Ошибка", message: "Недостаточно данных для сохранения", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: UIAlertAction.Style.cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        userInfo.append(contentsOf: buffer.returnArrayElements(numberOfElements: 2))
        
        videoMerger.mergeVideos(withFileURLs: userInfo) { (mergedVideo, error) in
            if error != nil {
                let errorMessage = "Could not merge videos: \(error?.localizedDescription ?? "error")"
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                self.present(alert, animated: true) {() -> Void in }
                return
            }
            
            // Handle a movie saving
            UISaveVideoAtPathToSavedPhotosAlbum(mergedVideo!.path,
                                                self,
                                                #selector(self.video(_:didFinishSavingWithError:contextInfo:)),
                                                nil)
        }
    }
}
extension CustomPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        startVideoCapture()
        let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as! NSURL
        let actualURL = videoURL.absoluteURL
        buffer.saveURLToArray(actualURL!)
    }
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        
        let alert = error == nil
            ? UIAlertController(title: "Успешно", message: "Видео сохранено", preferredStyle: .alert)
            : UIAlertController(title: "Ошибка", message: error?.localizedDescription, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ок", style: UIAlertAction.Style.cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}
