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

class ApiManager: CustomPickerViewController {
    
    var video = VideoManager()
    
    static var instance = ApiManager()
    
    
    private enum Constants {
        static let baseURL = ""
        
    }
    
    private enum EndPoints {
        static let uploads = ""
    }
    
    
    func uploadVideo(url: String) {
        
        guard let url = URL(string: url) else { return }
        
        let image = UIImage(named: "Notification")!
        let data = image.pngData()!
        
        let httpHeaders = ["Authorization": "Client-ID 1bd22b9ce396a4c"]
        
        upload(multipartFormData: { (multipartFormData) in
            
            multipartFormData.append(data, withName: "image")
            
        }, to: url,
           headers: httpHeaders) { (encodingCompletion) in
            
            switch encodingCompletion {
                
            case .success(request: let uploadRequest,
                          streamingFromDisk: let streamingFromDisk,
                          streamFileURL: let streamFileURL):
                
                print(uploadRequest)
                print(streamingFromDisk)
                print(streamFileURL ?? "strimingFileURL is NIL")
                
                uploadRequest.validate().responseJSON(completionHandler: { (responseJSON) in
                    
                    switch responseJSON.result {
                        
                    case .success(let value):
                        print(value)
                    case .failure(let error):
                        print(error)
                    }
                })
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    func uploadVideoTwo(url: String) { // local video file path..
        
        
        
        
    }
    
    
}


