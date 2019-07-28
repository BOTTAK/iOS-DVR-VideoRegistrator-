//
//  CustomPickerViewController.swift
//  iOS-RecordVideo
//
//  Created by Владимир Королев on 21/07/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit
import AVFoundation

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
    
    let videoTrimmer = VideoTrimmer()
    
    open var fullVideoDuration = 20.0 // expected video file duration after montage in seconds

    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addRecognizers()
        setupAndAddSubviews()
        delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startVideoCapture()
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
        stopVideoCapture()
        let settingsController = UIHelper.storyboard.instantiateViewController(withIdentifier: SettingViewController.self)
        present(settingsController, animated: true, completion: nil)
    }
    
    // MARK: Swipe handling
    @objc func swipeLeft() {
        notificationLabel.changeTextAndAnimate(text: "Left")
        stopVideoCapture()
    }
    
    @objc func swipeRight() {
        notificationLabel.changeTextAndAnimate(text: "Right")
        notificationLabel.showTimer(seconds: Int(fullVideoDuration))
        Timer.scheduledTimer(timeInterval: fullVideoDuration,
                             target: self,
                             selector: #selector(swipeRightTimerAction),
                             userInfo: nil, repeats: false)
        view.isUserInteractionEnabled = false
    }
    
    @objc func swipeRightTimerAction() {
        stopVideoCapture()
        view.isUserInteractionEnabled = true
    }
    
    @objc func swipeDown() {
        notificationLabel.changeTextAndAnimate(text: "Down")
        notificationLabel.showTimer(seconds: Int(fullVideoDuration / 2))
        Timer.scheduledTimer(timeInterval: fullVideoDuration / 2,
                             target: self,
                             selector: #selector(swipeDownTimerAction),
                             userInfo: nil, repeats: false)
        view.isUserInteractionEnabled = false
    }
    
    @objc func swipeDownTimerAction() {
        stopVideoCapture()
        view.isUserInteractionEnabled = true
    }
    
}
extension CustomPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
            print("Error parsing info for an URL")
            return
        }
        
        videoTrimmer.trimVideo(sourceURL: videoURL, duration: fullVideoDuration) { (newVideo, error) in
            
            
            guard let trimmedVideoURL = newVideo?.fileURL else {
                print("Error creating URL - \(error?.localizedDescription ?? "No error")")
                return
            }
            
            UISaveVideoAtPathToSavedPhotosAlbum(trimmedVideoURL.path,
                                                self,
                                                #selector(self.video(_:didFinishSavingWithError:contextInfo:)),
                                                nil)
        }
        startVideoCapture()
    }
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        
        let alert = error == nil
            ? UIAlertController(title: "Успешно", message: "Видео сохранено", preferredStyle: .alert)
            : UIAlertController(title: "Ошибка", message: error?.localizedDescription, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ок", style: UIAlertAction.Style.cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}

