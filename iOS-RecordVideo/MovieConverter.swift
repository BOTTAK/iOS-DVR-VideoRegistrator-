//
//  MovieConverter.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 7/16/19.
//  Copyright © 2019 BOTTAK. All rights reserved.
//

import Foundation
import AVFoundation

let kErrorDomain = "VideoBuilder"
let kFailedToStartAsserWriteError = 0
let kFailedToAppendPixelBufferError = 1


class VideoBuilding: NSObject {
    
    var buffer: [CVPixelBuffer] = []
    var fps: Int32 = 0
    var videoWriter: AVAssetWriter?
    
    
    init(buffer: [CVPixelBuffer], fps: Int32){
        self.buffer = buffer
        self.fps = fps
    }

    
    // Function for build video in array's image buffer
    func buildVideo(_ progress: @escaping ((Progress) -> Void), succes: @escaping ((URL) -> Void), failure: ((NSError) -> Void)) {
        var error: NSError?
        
        let firstPixelBuffer = buffer.first!
        let width = CVPixelBufferGetWidth(firstPixelBuffer)
        let height = CVPixelBufferGetHeight(firstPixelBuffer)
        
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) [0] as NSString
        let videoOutputUrl = URL(fileURLWithPath: documentPath.appendingPathComponent("FinalVideo.mov"))
        
        do {
            try FileManager.default.removeItem(at: videoOutputUrl)
        } catch {}
        
        do {
            try videoWriter = AVAssetWriter(outputURL: videoOutputUrl, fileType: AVFileType.mov)
        } catch let writeError as NSError {
            error = writeError
            videoWriter = nil
        }
        
        if let videoWriter = videoWriter {
            let videoSetting: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: width,
                AVVideoHeightKey: height,
            ]
            
            let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSetting)
            
            let attr = CVBufferGetAttachments(firstPixelBuffer, .shouldPropagate) as! [String : Any]
            
            let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: videoWriterInput,
                sourcePixelBufferAttributes: attr
            )
            
            assert(videoWriter.canAdd(videoWriterInput))
            videoWriterInput.expectsMediaDataInRealTime = true
            videoWriter.add(videoWriterInput)
            
            if videoWriter.startWriting() {
                videoWriter.startSession(atSourceTime:  CMTime.zero)
                assert(pixelBufferAdaptor.pixelBufferPool != nil)
                
                
                let mediaQueue = DispatchQueue(label: "mediaQueue")
                
                videoWriterInput.requestMediaDataWhenReady(on: mediaQueue) { [weak self] in
                    guard let final = self else {return}
                    let frameDuration = CMTimeMake(value: 1, timescale: final.fps)
                    let currentProgress = Progress(totalUnitCount: Int64(final.buffer.count))
                    
                    
                    var frameCount: Int64 = 0
                    var remainingPhotoUrls = final.buffer
                    
                    
                    while !remainingPhotoUrls.isEmpty {
                        let nextPhotosURL = remainingPhotoUrls.remove(at: 0)
                        let lastFrameTime = CMTimeMake(value: frameCount, timescale: final.fps)
                        let presentationTime = frameCount == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, frameDuration)
                        
                        while !videoWriterInput.isReadyForMoreMediaData {
                            Thread.sleep(forTimeInterval: 0.1)
                        }
                        
                        pixelBufferAdaptor.append(nextPhotosURL, withPresentationTime: presentationTime)
                        
                        frameCount += 1
                        
                        currentProgress.completedUnitCount = frameCount
                        progress(currentProgress)
                        
                    }
                    
                    videoWriterInput.markAsFinished()
                    videoWriter.finishWriting {
                        if error == nil {
                            succes(videoOutputUrl)
                        }
                        
                        final.videoWriter = nil
                        
                    }
                    
                }
                
                
            }else {
                error = NSError(
                    domain: kErrorDomain,
                    code: kFailedToStartAsserWriteError,
                    userInfo: ["description": "AVAssetWriter failed to start writing"]
                )
            }
            
        }
        
        if let error = error {
            failure(error)
        }
        
    }
    
    
}
