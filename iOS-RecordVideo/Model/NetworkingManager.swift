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
import SwiftyJSON

typealias ClosureReturnToken = (String) -> ()

struct APIConstants {
    static let login = "9@m.ru"
    static let password = "111111"
    static let expireDateString = "2019-12-01 12:00:00"
    static let parameters: Parameters = ["login": APIConstants.login,
                                         "password": APIConstants.password,
                                         "expired_at": APIConstants.expireDateString]
    static let tokensURL = URL(string: "https://api.detect.camera/tokens")!
    static let uploadVideoURL = URL(string:"https://api.detect.camera/videos")!
    
    private init() {}
}

class NetworkingManager {
    
    var video = VideoManager()
    
    class func authorisation(complition: @escaping ClosureReturnToken) {
        Alamofire.request(APIConstants.tokensURL,
                          method: .post,
                          parameters: APIConstants.parameters).responseJSON { response in
                            
            let json = JSON(response.result.value!)
            guard let token = json["token"].string else { fatalError() }
            complition(token)
        }
    }
    
    
    class func uploadVideo(videoUrl: URL, location: CLLocation, token: String) {
        
        let latitude = location.coordinate.latitude
        let longtitude = location.coordinate.longitude
        let speed = location.speed
        print(videoUrl)
        
        let latitudeData = withUnsafeBytes(of: latitude) { Data($0) }
        let longtitudeData = withUnsafeBytes(of: longtitude) { Data($0) }
        let speedData = withUnsafeBytes(of: speed) { Data($0) }
        
        guard let url: URL =  URL(string:"https://api.detect.camera/videos") else { fatalError() }
        
        let httpHeaders = ["Authorization": "Bearer \(token)", "Cache-Control": "no-cache"]
        
        upload(multipartFormData: { (multipartFormData) in
//            multipartFormData.append(latitudeData, withName: "location_data[latitude]")
//            multipartFormData.append(longtitudeData, withName: "location_data[longitude]")
//            multipartFormData.append(speedData, withName: "location_data[speed]")
            multipartFormData.append(<#T##data: Data##Data#>, withName: "violations[0][violation_id]")
            multipartFormData.append(videoUrl, withName: "videoFile", fileName: "secondTry.mp4", mimeType: "video/mp4")
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
    //
    //    class func uploadToServer(url: URL) {
    //
    //        Alamofire.upload(
    //            multipartFormData: { multipartFormData in
    //                multipartFormData.append(url, withName: "unicorn")
    //                multipartFormData.append(rainbowImageURL, withName: "rainbow")
    //        },
//            to: "https://httpbin.org/post",
//            encodingCompletion: { encodingResult in
//                switch encodingResult {
//                case .success(let upload, _, _):
//                    upload.responseJSON { response in
//                        debugPrint(response)
//                    }
//                case .failure(let encodingError):
//                    print(encodingError)
//                }
//        }
//        )
//    }
    
        
    }
    
    
   
    

