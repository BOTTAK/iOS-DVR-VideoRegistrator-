//
//  NameGenerator.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 7/22/19.
//  Copyright © 2019 BOTTAK. All rights reserved.
//

import Foundation

let dateFormatter = DateFormatter()
var videoName: String {
    let date = Date()
    dateFormatter.dateFormat = "H:m:ss.SSSS"
    return dateFormatter.string(from: date)
}
