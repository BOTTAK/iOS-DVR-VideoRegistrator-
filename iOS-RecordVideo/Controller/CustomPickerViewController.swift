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
    let buffer = Buffer()
    let videoMerger = DPVideoMerger()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(swipeLeftRecognizer)
        view.addGestureRecognizer(swipeRightRecognizer)
        view.addGestureRecognizer(swipeDownRecognizer)
        
        delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        notificationLabel.center = view.center
        view.addSubview(notificationLabel)
        
        startRecording()
        
    }
    
    private func startRecording() {
        startVideoCapture()
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: buffer.size, target: self, selector: #selector(timerRepeat), userInfo: nil, repeats: true)
    }
    
    @objc func timerRepeat() {
        stopVideoCapture()
    }
    
    @objc func swipeLeft() {
        notificationLabel.changeTextAndAnimate(text: "Left")
        let expectedNumberOfFragments = 4
        if buffer.returnArrayElements(numberOfElements: expectedNumberOfFragments).count < expectedNumberOfFragments {
            let alert =  UIAlertController(title: "Ошибка", message: "Недостаточно данных для сохранения", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: UIAlertAction.Style.cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            videoMerger.mergeVideos(withFileURLs: buffer.returnArrayElements(numberOfElements: 2)) { (mergedVideo, error) in
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
    }
    
    @objc func swipeDown() {
        
        notificationLabel.changeTextAndAnimate(text: "Down")
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
