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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       let _ = loadViewFromNib()
    }
    
    @IBAction func settingButtonTapped(_ sender: Any) {
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = Bundle.init(for: type(of: self))
        let nib = UINib(nibName: "MainViewXib", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
        return view
        
        
    }

    

}
