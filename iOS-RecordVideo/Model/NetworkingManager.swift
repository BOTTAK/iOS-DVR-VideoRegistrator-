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

typealias TokenBlock = (String) -> ()
typealias VideoUploadBlock = (Any?, Error?) -> ()

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

final class NetworkingManager {
    
    public var token: String = "invalidToken"
    
    public func authorisation(complition: @escaping TokenBlock) {
        Alamofire.request(APIConstants.tokensURL,
                          method: .post,
                          parameters: APIConstants.parameters).responseJSON { response in
                            
                            let json = JSON(response.result.value!)
                            guard let validToken = json["token"].string else { fatalError() }
                            complition(validToken)
        }
    }
    
    public func uploadVideo(videoUrl: URL, location: CLLocation, complitionHandler: @escaping VideoUploadBlock) {
        
        //        let latitude = location.coordinate.latitude
        //        let longtitude = location.coordinate.longitude
        //        let speed = location.speed
        
        //        let latitudeData = withUnsafeBytes(of: latitude) { Data($0) }
        //        let longtitudeData = withUnsafeBytes(of: longtitude) { Data($0) }
        //        let speedData = withUnsafeBytes(of: speed) { Data($0) }
        
        let httpHeaders = ["Authorization": "Bearer \(token)", "Cache-Control": "no-cache"]
        
        upload(multipartFormData: { (multipartFormData) in
            //            multipartFormData.append(latitudeData, withName: "location_data[latitude]")
            //            multipartFormData.append(longtitudeData, withName: "location_data[longitude]")
            //            multipartFormData.append(speedData, withName: "location_data[speed]")
            //            multipartFormData.append(<#T##data: Data##Data#>, withName: "violations[0][violation_id]")
            multipartFormData.append(videoUrl, withName: "videoFile", fileName: "secondTry.mp4", mimeType: "video/mp4")
        }, to: APIConstants.uploadVideoURL,
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
                        complitionHandler(value, nil)
                    case .failure(let error):
                        complitionHandler(nil, error)
                    }
                })
                
            case .failure(let error):
                complitionHandler(nil, error)
            }
        }
    }
}


   
    

