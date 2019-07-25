//
//  NameGenerator.swift
//  iOS-RecordVideo
//
//  Created by Владимир Королев on 25/07/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import Foundation

let dateFormatter = DateFormatter()
var videoName: String {
    let date = Date()
    dateFormatter.dateFormat = "H:m:ss.SSSS"
    return dateFormatter.string(from: date)
}
