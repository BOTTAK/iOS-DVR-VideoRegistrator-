//
//  CameraModel.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 7/16/19.
//  Copyright © 2019 BOTTAK. All rights reserved.
//

import Foundation

struct Camera {
    struct Record {
        struct Response {
            let url: URL?
            let error: Error?
        }
        
        struct ViewModel {
            let title: String
            let message: String
        }
    }
}
