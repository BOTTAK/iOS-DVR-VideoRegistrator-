//
//  VideoTrimmer.swift
//  iOS-RecordVideo
//
//  Created by Владимир Королев on 25/07/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//
import AVFoundation
import UIKit

class VideoManager {
    
    func trimVideo(sourceURL: URL, duration: Double, metaData: AVMutableMetadataItem, completion: @escaping (Result<URL, Error>)->Void) {
        
        guard sourceURL.isFileURL else { fatalError() }
        
        let asset = AVURLAsset(url: sourceURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        
        guard let exportSession = AVAssetExportSession(asset: asset,
                                                       presetName: AVAssetExportPresetPassthrough) else { fatalError() }
        
        exportSession.timeRange = generateRange(startTime: asset.duration.seconds - duration,
                                                endTime: asset.duration.seconds)
        exportSession.outputURL = FileManager.createNewFilePath(fileName: videoName)
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.metadata = [metaData]
        
        exportSession.exportAsynchronously(completionHandler: {() -> Void in
            switch exportSession.status {
            case .failed:
                print(exportSession.error ?? "No error")
                completion(.failure(exportSession.error!))
            case .cancelled:
                let error = NSError(domain: "VideoApp", code: 00, userInfo: ["Message": "Export cancelled"])
                completion(.failure(error))
            case .completed:
                guard let correctURL = exportSession.outputURL else {
                    print("error getting url")
                    return
                }
                print("Successful! \(correctURL)")
                completion(.success(correctURL))
            default:
                fatalError()
            }
        })
    }
    
    private func generateRange(startTime: Double, endTime: Double) -> CMTimeRange {
        let defaultTimeScale: CMTimeScale = 600
        let rangeStart = CMTime(seconds: startTime, preferredTimescale: defaultTimeScale)
        let rangeEnd = CMTime(seconds: endTime, preferredTimescale: defaultTimeScale)
        return CMTimeRangeMake(start: rangeStart, duration: rangeEnd)
    }
}

// MARK: FileManager extensions
extension FileManager {
    class func removeFileAtURLIfExists(url: URL) {
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            try FileManager.default.removeItem(at: url)
        }
        catch let error {
            print("TrimVideo - Couldn't remove existing destination file: \(String(describing: error))") // TODO: change prints to alert error
        }
    }
}

extension FileManager {
    class func createNewFilePath(fileName: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        let filePath = documentsDirectory.appendingPathComponent("\(fileName).mp4")
        guard filePath.isFileURL else { fatalError() }
        removeFileAtURLIfExists(url: filePath)
        return filePath
    }
}
