//
//  Buffer.swift
//  iOS-RecordVideo
//
//  Created by Владимир Королев on 21/07/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit

class Buffer {
    
    public let size = 5.0
    private var videoPartsArray: [NSData] = []
    private var videoURLArray: [URL] = []
    private let dateFormatter = DateFormatter()
    private var imageName: String {
        let date = Date()
        dateFormatter.dateFormat = "H:m:ss.SSSS"
        return dateFormatter.string(from: date)
    }
    
    open func saveURLToArray(_ URL: URL) {
        if videoURLArray.count < 10 {
            videoURLArray.append(URL)
        } else {
            videoURLArray.removeFirst()
            videoURLArray.append(URL)
        }
        print("saved")
    }
    
    open func returnArrayElements(numberOfElements: Int) -> [URL] {
        print("returned \(videoURLArray.suffix(numberOfElements))")
        return videoURLArray.suffix(numberOfElements)
        
    }
}
