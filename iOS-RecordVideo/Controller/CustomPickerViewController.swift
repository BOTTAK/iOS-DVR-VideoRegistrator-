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
    
    open var fullVideoDuration = 5 // expected video file duration after montage in seconds

    
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
    @objc func swipeLeft() {
        notificationLabel.changeTextAndAnimate(text: "Left")
        stopVideoCapture()
    }
    
    @objc func swipeRight() {
        notificationLabel.changeTextAndAnimate(text: "Right")
    }
    
    @objc func swipeDown() {
        notificationLabel.changeTextAndAnimate(text: "Down")
    }
    
}
extension CustomPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as! NSURL
        let actualURL = videoURL.absoluteURL
        
        
        let startTime = CMTime(seconds: 1, preferredTimescale: 1000)
        let endTime = CMTime(seconds: 3, preferredTimescale: 1000)
        
        videoTrimmer.trimVideo(sourceURL: actualURL!,
                               trimPoints: [(startTime, endTime)]) { (newFileUrl, error) in
                                if error != nil {
                                    print("error \(error?.localizedDescription)")
                                } else {
                                    UISaveVideoAtPathToSavedPhotosAlbum(newFileUrl!.path,
                                                                        self,
                                                                        #selector(self.video(_:didFinishSavingWithError:contextInfo:)),
                                                                        nil)
                                }
        }
    }
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        
        let alert = error == nil
            ? UIAlertController(title: "Успешно", message: "Видео сохранено", preferredStyle: .alert)
            : UIAlertController(title: "Ошибка", message: error?.localizedDescription, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ок", style: UIAlertAction.Style.cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}

