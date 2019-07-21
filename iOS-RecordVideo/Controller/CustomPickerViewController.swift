//
//  CustomPickerViewController.swift
//  iOS-RecordVideo
//
//  Created by Владимир Королев on 21/07/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit


protocol CustomPickerControllerDelegate: class {
    func userDidSwapLeft()
    func userDidSwapRight()
    func userDidSwapDown()
}

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
    
    weak var swipeDelegate: CustomPickerControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(swipeLeftRecognizer)
        view.addGestureRecognizer(swipeRightRecognizer)
        view.addGestureRecognizer(swipeDownRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        notificationLabel.center = view.center
        view.addSubview(notificationLabel)
    }
    
    @objc func swipeLeft() {
        swipeDelegate?.userDidSwapLeft()
        
        notificationLabel.changeTextAndAnimate(text: "Left")
    }
    
    @objc func swipeRight() {
        swipeDelegate?.userDidSwapRight()
        
        notificationLabel.changeTextAndAnimate(text: "Right")
    }
    
    @objc func swipeDown() {
        swipeDelegate?.userDidSwapDown()
        
        notificationLabel.changeTextAndAnimate(text: "Down")
    }

}
