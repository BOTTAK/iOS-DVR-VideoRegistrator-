//
//  Buffer.swift
//  iOS-RecordVideo
//
//  Created by Владимир Королев on 21/07/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit

class Buffer {
    
    public let size = 1.0
    private var videoPartsArray: [NSData] = []
    private let dateFormatter = DateFormatter()
    private var imageName: String {
        let date = Date()
        dateFormatter.dateFormat = "H:m:ss.SSSS"
        return dateFormatter.string(from: date)
    }
    
    open func addVideoFragment(_ fragment: NSData) {
        if videoPartsArray.count < 120 {
            videoPartsArray.append(fragment)
            saveFragment()
        } else {
            videoPartsArray.removeFirst()
            videoPartsArray.append(fragment)
            saveFragment()
        }
    }
    
    private func saveFragment() {
        let path = try! FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory,
                                                in: FileManager.SearchPathDomainMask.userDomainMask,
                                                appropriateFor: nil,
                                                create: false)
        let newPath = path.appendingPathComponent("/\(imageName).mp4")
        do {
            try videoPartsArray.last?.write(to: newPath)
            print("saved \(newPath)")
        } catch {
            print("error saving \(error.localizedDescription)")
        }
    }
    
}
