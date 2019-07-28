//
//  UIHelper.swift
//  iOS-RecordVideo
//
//  Created by Владимир Королев on 28/07/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit

class UIHelper {
    
    static let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    class func showError(error: String, action: UIAlertAction? = nil, controller: UIViewController) {
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            
            if let alertAction = action {
                alert.addAction(alertAction)
            }
            
            controller.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension UIStoryboard { // used to call controllers with same id as a view controller type
    func instantiateViewController(withIdentifier typeIdentifier: UIViewController.Type) -> UIViewController {
        return instantiateViewController(withIdentifier: String(describing: typeIdentifier))
    }
}
