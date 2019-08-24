//
//  VideoOverlayService.swift
//  TestAVMutableVideoComposition
//
//  Created by Alexey on 21/08/2019.
//  Copyright © 2019 BOTTAK. All rights reserved.
//

import Foundation
import UIKit.UIColor
import AVFoundation

class VideoOverlayService {
    
    func addOverlayToVideo(videoUrl: URL, duration: Double, outputUrl: URL, type: AVFileType, meta: (AVMetadataItem, String), texts: [(start: Double, duration: Double, text: String)], progress progressClosure: @escaping (_ progress: Float) -> (), completion: @escaping (_ url: URL?) -> (), failure: @escaping (_ error: Swift.Error?) -> ()) {
        let composition = AVMutableComposition()
        
        let vidAsset = AVURLAsset(url: videoUrl as URL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        // get video track from asset
        let videoTrack: AVAssetTrack = vidAsset.tracks(withMediaType: AVMediaType.video).first!
        let vid_timerange = CMTimeRangeMake(start: CMTime.zero, duration: vidAsset.duration)
        // add video track to composition
        let compositionvideoTrack : AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        try! compositionvideoTrack.insertTimeRange(vid_timerange, of: videoTrack, at: CMTime.zero)
        compositionvideoTrack.preferredTransform = videoTrack.preferredTransform
        
        // add audio
        let audioTrack = vidAsset.tracks(withMediaType: AVMediaType.audio).first!
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
        try! compositionAudioTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: vidAsset.duration), of: audioTrack, at: CMTime.zero)
        
        //Watermark effect
        let videoSize = videoTrack.naturalSize
        
        let parentLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
        
        // add video layer
        let videoLayer = CALayer()
        videoLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
        parentLayer.addSublayer(videoLayer)
        
        for item in texts {
            let fixedItem: (start: Double, duration: Double, text: String) = (item.start - 0.01, item.duration + 0.01, item.text)
            let titleLayer = CATextLayer()
            titleLayer.string = fixedItem.text
            titleLayer.foregroundColor = UIColor.red.cgColor
            titleLayer.isWrapped = true
            titleLayer.frame = CGRect(x: 50, y: 50, width: 600, height: 200)
            titleLayer.beginTime = vidAsset.duration.seconds - duration
            titleLayer.duration = vidAsset.duration.seconds
            titleLayer.display()
            let animation = self.createShowHideAnimation(duration: fixedItem.duration, startTime: fixedItem.start)
            titleLayer.add(animation, forKey: UUID().uuidString)
            parentLayer.addSublayer(titleLayer)
        }
        
        let instructuon = AVMutableVideoCompositionInstruction()
        instructuon.timeRange = CMTimeRange(start: CMTime.zero, duration: composition.duration)
        let videotrack = composition.tracks(withMediaType: AVMediaType.video).first!
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videotrack)
        instructuon.layerInstructions = [layerInstruction]
        
        let layerComposition = AVMutableVideoComposition()
        layerComposition.frameDuration = CMTimeMake(value: 1, timescale: 25)
        layerComposition.renderSize = videoSize
        layerComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        layerComposition.instructions = [instructuon]
        
        //Create new videofile
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let docUrl = URL(fileURLWithPath: docDir)
        let movieDestinationURl = docUrl.appendingPathComponent("result.mov")
        try? FileManager.default.removeItem(at: movieDestinationURl)
        
        //Use AVAssetExportVideo to export video
        let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        assetExport?.videoComposition = layerComposition
        assetExport?.outputFileType = type
        assetExport?.outputURL = outputUrl
        
        let dateMetadata = AVMutableMetadataItem()
        dateMetadata.keySpace = AVMetadataKeySpace.quickTimeMetadata
        dateMetadata.key = AVMetadataKey.quickTimeMetadataKeyCreationDate as NSCopying & NSObjectProtocol
        dateMetadata.identifier = AVMetadataIdentifier.quickTimeMetadataCreationDate
        dateMetadata.value = meta.1 as NSCopying & NSObjectProtocol
        
        assetExport?.metadata = [meta.0, dateMetadata]
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer: Timer) in
            if let progress = assetExport?.progress {
                progressClosure(progress)
            }
        }
        assetExport?.exportAsynchronously(completionHandler: {
            timer.invalidate()
            switch assetExport?.status {
            case .failed? :
                failure(assetExport?.error)
            case .cancelled? :
                failure(assetExport?.error)
            default:
                completion(assetExport?.outputURL)
            }
        })
    }
    
    func createShowHideAnimation(duration: CFTimeInterval,startTime:Double)->CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath:"opacity")
        animation.duration = duration
        animation.calculationMode = CAAnimationCalculationMode.discrete
        animation.values = [0,1,1,0,0]
        animation.keyTimes = [0,0.001,0.99,0.999,1]
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.both
        animation.beginTime = AVCoreAnimationBeginTimeAtZero + startTime
        return animation
    }
    
    func createShowHideAnimationWithFade(duration: CFTimeInterval,startTime:Double)->CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath:"opacity")
        animation.duration = duration
        animation.values = [0,0.5,1,0.5,0]
        animation.keyTimes = [0,0.25,0.5,0.75,1]
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.both
        animation.beginTime = AVCoreAnimationBeginTimeAtZero + startTime
        return animation
    }
    
    private func generateRange(startTime: Double, endTime: Double) -> CMTimeRange {
        let defaultTimeScale: CMTimeScale = 25
        let rangeStart = CMTime(seconds: startTime, preferredTimescale: defaultTimeScale)
        let rangeEnd = CMTime(seconds: endTime, preferredTimescale: defaultTimeScale)
        return CMTimeRangeMake(start: rangeStart, duration: rangeEnd)
    }
}
