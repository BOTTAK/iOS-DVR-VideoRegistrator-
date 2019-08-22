//
//  MainViewXib.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 8/22/19.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit

class MainViewXib: UIView {

   
    //MARK: - Outlets
    @IBOutlet weak var lotitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
         backgroundColor = .white
    }
    
    
    //MARK: - Actions
    
    @IBAction func settingButtonTapped(_ sender: Any) {
    }
    
    

    

}
