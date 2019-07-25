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
    
    func trimVideo(sourceURL: URL, trimPoints: TrimPoints, completion: TrimCompletion?) {
        
        let filePath = createNewFilePath(fileName: videoName)
        
        guard sourceURL.isFileURL else { return }
        guard filePath.isFileURL else { return }
        
        let asset = AVURLAsset(url: sourceURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        
        let startDate = Date()
        

        let preferredPreset = AVAssetExportPresetPassthrough
        
        if  verifyPresetForAsset(preset: preferredPreset, asset: asset) {
            
            let composition = AVMutableComposition()
            let videoCompTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: CMPersistentTrackID())
            let audioCompTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID())
            
            guard let assetVideoTrack: AVAssetTrack = asset.tracks(withMediaType: .video).first else { return }
            guard let assetAudioTrack: AVAssetTrack = asset.tracks(withMediaType: .audio).first else { return }
            
            videoCompTrack!.preferredTransform = assetVideoTrack.preferredTransform
            
            var accumulatedTime = CMTime.zero
            for (startTimeForCurrentSlice, endTimeForCurrentSlice) in trimPoints {
                let durationOfCurrentSlice = CMTimeSubtract(endTimeForCurrentSlice, startTimeForCurrentSlice)
                let timeRangeForCurrentSlice = CMTimeRangeMake(start: startTimeForCurrentSlice, duration: durationOfCurrentSlice)
                
                do {
                    try videoCompTrack!.insertTimeRange(timeRangeForCurrentSlice, of: assetVideoTrack, at: accumulatedTime)
                    try audioCompTrack!.insertTimeRange(timeRangeForCurrentSlice, of: assetAudioTrack, at: accumulatedTime)
                    accumulatedTime = CMTimeAdd(accumulatedTime, durationOfCurrentSlice)
                }
                catch let compError {
                    print("TrimVideo: error during composition: \(compError)")
                    completion?(nil, compError)
                }
            }
            
            guard let exportSession = AVAssetExportSession(asset: composition, presetName: preferredPreset) else { return }
            
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
                    let endDate = Date()
                    let time = endDate.timeIntervalSince(startDate)
                    print(time)
                    print("Successful!")
                    print(exportSession.outputURL ?? "NO OUTPUT URL")
                    completion?(exportSession.outputURL, nil)
                default:
                    break
                }
            })
        }
        else {
            print("TrimVideo - Could not find a suitable export preset for the input video")
            let error = NSError(domain: "com.bighug.ios", code: -1, userInfo: nil)
            completion?(nil, error)
        }
    }
}
