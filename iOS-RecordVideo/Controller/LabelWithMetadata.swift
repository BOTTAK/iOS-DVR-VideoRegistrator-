//
//  LabelWithMetadata.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 19/08/2019.
//  Copyright © 2019 BOTTAK. All rights reserved.
//

import UIKit

class LabelWithMetadata: UILabel {
    
    var metadata: String! {
        willSet {
            text = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4040768046)
        textColor = #colorLiteral(red: 0.9607843137, green: 0.1921568627, blue: 0.1490196078, alpha: 1)
        highlightedTextColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        metadata = ""
        textAlignment = .center
    }
}
