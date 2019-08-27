//
//  CustomLongPress.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 01/08/2019.
//  Copyright © 2019 BOTTAK. All rights reserved.
//

import UIKit

protocol LongPressDelegate: class {
    func gestureDidEnd()
    func timerDidTick(_ time: Int)
}

class CustomLongPress: UILongPressGestureRecognizer {
    
    var timer = Timer()
    var count = 0
    weak var longTapDelegate: LongPressDelegate?
    
    var vc: VideoCapturingPickerController!
    
    init(target: Any?, action: Selector?, controller: VideoCapturingPickerController) {
        super.init(target: target, action: action)
        vc = controller
        longTapDelegate = controller
        minimumPressDuration = 0.3
        delegate = controller
        controller.view.addGestureRecognizer(self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        if vc.swipeEnded {
            super.touchesBegan(touches, with: event)
            startTimer()
            vc.swipeEnded = false
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        vc.swipeEnded = false
        longTapDelegate?.gestureDidEnd()
        timer.invalidate()
        count = 0
    }
    
    private func startTimer() {
        count = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.longTapDelegate?.timerDidTick(self.count * 10)
            self.count += 1
        }
    }
}
