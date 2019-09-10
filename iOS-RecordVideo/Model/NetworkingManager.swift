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
typealias VideoUploadBlock = (Swift.Result<Any, Error>)->Void

struct APIConstants {
    static let login = "9@m.ru"
    static let password = "111111"
    static let expireDateString = "2019-12-01 12:00:00"
    static let recordedAtConstString = "2019-06-01 12:00:00"
    static let regNumber = "Х857ОР170RUS"
    static let violationID = "1"
    static let streetSide = "ODD"
    static let time = "1487087440"
    static let atTimeStamp = "1487087300"
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
                            guard let validToken = JSON(response.result.value)["token"].string else { return }
                            complition(validToken)
        }
    }
    
    public func uploadVideo(videoUrl: URL, complitionHandler: @escaping VideoUploadBlock) {
        let asset = AVURLAsset(url: videoUrl, options: nil)
        
        guard let metadata = asset.metadata.first?.value?.description else { fatalError() }
        print(asset.metadata.first?.value)
        let parsedMetaDataArray = metadata.components(separatedBy: "+")
        print(parsedMetaDataArray)
        let latitude = parsedMetaDataArray[1]
        let longtitude = parsedMetaDataArray[2].dropFirst()
        let attitude = parsedMetaDataArray[3].dropLast(5)

//        let speed = (asset.metadata.first?.extraAttributes?.values.dropFirst().first as! NSNumber).stringValue

//        print("speed - \(speed)")


//                let speed = (asset.metadata.first?.extraAttributes?.values.dropFirst().first as! NSNumber).stringValue // TODO: hardcoded



//        let speed = "10"

//        let speed = asset.metadata.first?.extraAttributes?[AVMetadataExtraAttributeKey.init(rawValue: "dataType")] as! NSNumber

        let speed = asset.metadata[1].value

//        let speed = "10"

        print("speed - \(speed)")


//        guard let date = asset.metadata[1].value?.description.dropLast(5) else {fatalError()}

//        print(latitude, longtitude,  date)
//        


        guard let date = asset.metadata[2].value?.description.dropLast(5) else {fatalError()}

        print(latitude, longtitude, speed, date)


        let bearing = "127"
        let accuracy = "1"

        let latitudeData = latitude.data(using: .utf8)
        let longtitudeData = longtitude.data(using: .utf8)


//        let speedData = speed.data(using: .utf8)

//        let speedData = speed.description.data(using: .utf8)


        let speedData = speed!.description.data(using: .utf8)

        //        let violationIDData = APIConstants.violationID.data(using: .utf8)
        //        let regNumberData = APIConstants.regNumber.data(using: .utf8)
        let timeData = APIConstants.time.data(using: .utf8)
        let atTimeStampData = APIConstants.atTimeStamp.data(using: .utf8)
        let streetSideData = APIConstants.streetSide.data(using: .utf8)
        let recordedAtData = date.data(using: .utf8)
        let bearingData = bearing.data(using: .utf8)
        let accuracyData = accuracy.data(using: .utf8)
        let attitudeData = attitude.data(using: .utf8)

        let httpHeaders = ["Authorization": "Bearer \(token)", "Cache-Control": "no-cache"]

        upload(multipartFormData: { (multipartFormData) in

            //            multipartFormData.append(violationIDData!, withName: "violations[0][violation_id]")
            //            multipartFormData.append(regNumberData!, withName: "violations[0][reg_number]")
            multipartFormData.append(streetSideData!, withName: "street_side")
            multipartFormData.append(recordedAtData!, withName: "recorded_at")
            multipartFormData.append(latitudeData!, withName: "location_data[latitude]")
            multipartFormData.append(longtitudeData!, withName: "location_data[longitude]")
            multipartFormData.append(speedData!, withName: "location_data[speed]")
            multipartFormData.append(timeData!, withName: "location_data[time]")
            multipartFormData.append(atTimeStampData!, withName: "location_data[at_timestamp]")
            multipartFormData.append(bearingData!, withName: "location_data[bearing]")
            multipartFormData.append(accuracyData!, withName: "location_data[accuracy]")
            multipartFormData.append(attitudeData!, withName: "location_data[altitude]")
            multipartFormData.append(videoUrl, withName: "videoFile", fileName: "secondTry.mp4", mimeType: "video/mp4")

        }, to: APIConstants.uploadVideoURL,
           headers: httpHeaders) { (encodingCompletion) in

            switch encodingCompletion {

            case .success(request: let uploadRequest,
                          streamingFromDisk: let streamingFromDisk,
                          streamFileURL: let streamFileURL):
                uploadRequest.responseJSON(completionHandler: { (response) in
                    complitionHandler(.success(response))
                })

            case .failure(let error):
                complitionHandler(.failure(error))
                
            }
        }
    }
}
