//
//  SwipeNotificationLabel.swift
//  iOS-RecordVideo
//
//  Created by Владимир Королев on 21/07/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit

class SwipeNotificationLabel: UILabel {
    
    var secondsForTimer = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        sharedInit()
    }
    
    private func sharedInit() {
        textAlignment = .center
        textColor = .white
        alpha = 0.0
    }
    
    open func showAndHideLabel() {
        UIView.animate(withDuration: 0.8, delay: 0, options: .allowUserInteraction, animations: {
            self.alpha = 1.0
            self.alpha = 0.0
        }, completion: nil)
    }
    
    open func changeTextAndAnimate(text: String) {
        self.text = text
        showAndHideLabel()
    }
    
    open func showTimer(seconds: Int) {
        secondsForTimer = seconds
        Timer.scheduledTimer(timeInterval: 1,
                             target: self,
                             selector: #selector(timerAction),
                             userInfo: nil, repeats: true)
    }
    
    @objc func timerAction(timer: Timer) {
        if secondsForTimer == 0 {
            timer.invalidate()
        } else {
            changeTextAndAnimate(text: String(secondsForTimer))
            secondsForTimer -= 1
        }
    }
}
