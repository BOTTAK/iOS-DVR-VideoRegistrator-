//
//  SwipeNotificationLabel.swift
//  iOS-RecordVideo
//
//  Created by Владимир Королев on 21/07/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit

class SwipeNotificationLabel: UILabel {

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
    
    open func changeTextAndAnimate(text: String) {
        self.text = text
        showAndHideLabel()
    }
    
    open func showAndHideLabel() {
        UIView.animate(withDuration: 0.8, delay: 0, options: .allowUserInteraction, animations: {
            self.alpha = 1.0
            self.alpha = 0.0
        }, completion: nil)
    }
}
