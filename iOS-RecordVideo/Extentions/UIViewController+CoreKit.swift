//
//  UIViewController+CoreKit.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 6/20/19.
//  Copyright © 2019 BOTTAK. All rights reserved.
//

import UIKit

extension UIViewController {
    static func getFromStoryboard(withId id: String) -> UIViewController? {
        let  storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: id)
        return controller
        
    }
    
}
