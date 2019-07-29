//
//  ApiManager.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 6/20/19.
//  Copyright © 2019 BOTTAK. All rights reserved.
//

import Foundation
import Alamofire
import Photos

class ApiManager {
    
    var video = VideoManager()
    
    static var instance = ApiManager()
    
    
    private enum Constants {
        static let baseURL = ""
        
    }
    
    private enum EndPoints {
        static let uploads = ""
    }
    
    func uploadVideoToServer(onComplete: @escaping ([MainViewController]) -> Void) {
        
    }
    
   
   
    
    func uploadVideo(onComplete: @escaping ([VideoManager]) -> Void) { // local video file path..

        let urlString = Constants.baseURL + EndPoints.uploads
        
//        Alamofire.upload(.POST, "http://test.com", multipartFormData: { (formData:MultipartFormData) in
//            formData.appendBodyPart(fileURL: NSURL(fileURLWithPath: filePath), name: uname)
//        }, encodingCompletion: { encodingResult in
//            switch encodingResult {
//            case .Success(let upload, _, _):
//                upload.progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
//                    print(totalBytesRead)
//                }
//                upload.responseJSON { response in
//                    debugPrint(response)
//                    //uploaded
//                }
//            case .Failure(let encodingError):
//                //Something went wrong!
//                if DEBUG_MODE {
//                    print(encodingError)
//                }
//            }
//        })
        
    }
    
    
   
    
}
