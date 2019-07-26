//
//  VideoTrimmer.swift
//  iOS-RecordVideo
//
//  Created by Владимир Королев on 25/07/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//
import AVFoundation
import UIKit

class VideoTrimmer: NSObject {
    typealias TrimCompletion = ((URL?, Error?) -> Void)
    typealias TrimPoints = [(CMTime, CMTime)]
    
    func verifyPresetForAsset(preset: String, asset: AVAsset) -> Bool {
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
        let filteredPresets = compatiblePresets.filter { $0 == preset }
        return filteredPresets.count > 0 || preset == AVAssetExportPresetPassthrough
    }
    
    func getOutputPath( _ name: String ) -> String {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { fatalError() }
        let outputPath = "\(documentsDirectory)/\(name).mov"
        return outputPath
    }
    
    func removeFileAtURLIfExists(url: URL) {
        
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: url.path) else { return }
        
        do {
            try fileManager.removeItem(at: url)
        }
        catch let error {
            print("TrimVideo - Couldn't remove existing destination file: \(String(describing: error))")
        }
    }
    
    func createNewFilePath(fileName: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        let filePath = documentsDirectory.appendingPathComponent("\(fileName).mp4")
        return filePath
    }
    
    func trimVideo(sourceURL: URL, duration: Double, completion: TrimCompletion?) {
        
        let filePath = createNewFilePath(fileName: videoName)
        
        guard sourceURL.isFileURL else { return }
        guard filePath.isFileURL else { return }
        
        let asset = AVURLAsset(url: sourceURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        
        let preferredPreset = AVAssetExportPresetPassthrough
        
        let startTime = asset.duration - CMTime(seconds: duration, preferredTimescale: 600)
        let endTime = asset.duration
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: preferredPreset) else { fatalError() }
        
        let range = CMTimeRangeMake(start: startTime, duration: endTime)
        
        exportSession.timeRange = range
        exportSession.outputURL = filePath
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        removeFileAtURLIfExists(url: filePath as URL)
        
        exportSession.exportAsynchronously(completionHandler: {() -> Void in
            switch exportSession.status {
            case .failed:
                print(exportSession.error ?? "NO ERROR")
                completion?(nil, exportSession.error)
            case .cancelled:
                print("Export canceled")
                completion?(nil, nil)
            case .completed:
                //Video conversion finished
                print("Successful!")
                print(exportSession.outputURL ?? "NO OUTPUT URL")
                completion?(exportSession.outputURL, nil)
            default:
                break
            }
        })
    }
}
