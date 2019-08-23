//
//  VideoTrimmer.swift
//  iOS-RecordVideo
//
//  Created by Владимир Королев on 25/07/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import AVFoundation
import UIKit
import MediaWatermark

class VideoManager {
    var service: VideoOverlayService?
    private var dateFormatter = DateFormatter()
    
    func
        trimVideo(sourceURL: URL, duration: Double, location: AVMetadataItem, labels: [String], startTime: Date, geolocationStorage: GeolocationStorage, date: String, completion completionClosure: @escaping (Result<URL, Error>)->Void) {
        
        let outputUrl = FileManager.createNewFilePath(fileName: videoName)
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        var itemsForService = [(start: Double, duration: Double, text: String)]()
        for (index, record) in geolocationStorage.records.enumerated() {
            let text = "\(record.location.coordinate.latitude.description.dropLast(8))  \(record.location.coordinate.longitude.description.dropLast(8)) \(record.location.speed * 3.6), \(dateFormatter.string(from: record.location.timestamp))"
            var duration: Double = 1
            let nextItemIndex = index + 1
            if nextItemIndex < geolocationStorage.records.count {
                let nextItem = geolocationStorage.records[nextItemIndex]
                duration = nextItem.timecode.timeIntervalSince(record.timecode)
            }
            let item: (start: Double, duration: Double, text: String) = (record.timecode.timeIntervalSince(startTime), duration, text)
            itemsForService.append(item)
        }
        
        let service = VideoOverlayService()
        service.addOverlayToVideo(videoUrl: sourceURL, duration: duration,
                                  outputUrl: outputUrl, type: AVFileType.mp4, meta: (location, date),
                                  texts: itemsForService, progress: { (_ progress: Float) in
            print("progress: \(progress)")
        }, completion: {[weak self] (_ url: URL?) in
            completionClosure(.success(url!))
            self?.service = nil
        }) {[weak self] (_ error: Error?) in
            completionClosure(.failure(error!))
            self?.service = nil
        }
        self.service = service
        
//        guard sourceURL.isFileURL else { fatalError() }
//        addLabels(toVideo: sourceURL, labelsText: labels) { (result) in
//            switch result {
//            case let .failure(error):
//                completion(.failure(error))
//            case let .success(urlWithLabels):
//                let asset = AVURLAsset(url: urlWithLabels, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
//                if asset.duration.seconds < duration {
//                    completion(.failure(NSError(domain: "Video", code: 1056, userInfo: [NSLocalizedDescriptionKey : "Cannot create video with \(Int(duration)) sec duration because it is not recorded yet"])))
//                    return
//                }
//                guard let exportSession = AVAssetExportSession(asset: asset,
//                                                               presetName: AVAssetExportPresetPassthrough) else { fatalError() }
//
//                exportSession.timeRange = self.generateRange(startTime: asset.duration.seconds - duration,
//                                                        endTime: asset.duration.seconds)
//                exportSession.outputURL = FileManager.createNewFilePath(fileName: videoName)
//                exportSession.outputFileType = AVFileType.mp4
//                exportSession.shouldOptimizeForNetworkUse = true
//
//                let dateMetadata = AVMutableMetadataItem()
//                dateMetadata.keySpace = AVMetadataKeySpace.quickTimeMetadata
//                dateMetadata.key = AVMetadataKey.quickTimeMetadataKeyCreationDate as NSCopying & NSObjectProtocol
//                dateMetadata.identifier = AVMetadataIdentifier.quickTimeMetadataCreationDate
//                dateMetadata.value = date as NSCopying & NSObjectProtocol
//
//                exportSession.metadata = [location, dateMetadata]
//                print(exportSession.metadata?.first?.value)
//
//                exportSession.exportAsynchronously(completionHandler: {() -> Void in
//                    switch exportSession.status {
//                    case .failed:
//                        print(exportSession.error ?? "No error")
//                        completion(.failure(exportSession.error!))
//                    case .cancelled:
//                        let error = NSError(domain: "VideoApp", code: 00, userInfo: ["Message": "Export cancelled"])
//                        completion(.failure(error))
//                    case .completed:
//                        guard let correctURL = exportSession.outputURL
//                            else {
//                                print("error getting url")
//                                return
//                        }
//                        print("Successful! \(correctURL)")
//                        completion(.success(correctURL))
//                    default:
//                        fatalError()
//                    }
//                })
//            }
//        }
    }
    
    private func generateRange(startTime: Double, endTime: Double) -> CMTimeRange {
        let defaultTimeScale: CMTimeScale = 600
        let rangeStart = CMTime(seconds: startTime, preferredTimescale: defaultTimeScale)
        let rangeEnd = CMTime(seconds: endTime, preferredTimescale: defaultTimeScale)
        return CMTimeRangeMake(start: rangeStart, duration: rangeEnd)
    }
    
    private func addLabels(toVideo url: URL, labelsText: [String], completion: @escaping (Result<URL, Error>) -> Void) {
        if let item = MediaItem(url: url) {
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                              NSAttributedString.Key.font: UIFont.systemFont(ofSize: 35)]
            
            DispatchQueue.main.async {
                let lattitudeattrStr = NSAttributedString(string: labelsText[0], attributes: attributes)
                let longtitudeattrStr = NSAttributedString(string: labelsText[1], attributes: attributes)
                let speedattrStr = NSAttributedString(string: labelsText[2], attributes: attributes)
                let dateatrStr = NSAttributedString(string: labelsText[3], attributes: attributes)
                
                let firstElement = MediaElement(text: lattitudeattrStr)
                firstElement.frame = CGRect(x: 0, y: 0, width: item.size.width, height: 50)
                
                let secondElement = MediaElement(text: longtitudeattrStr)
                secondElement.frame = CGRect(x: 0, y: 50, width: item.size.width, height: 50)
                
                let thirdElement = MediaElement(text: speedattrStr)
                thirdElement.frame = CGRect(x: 0, y: 100, width: item.size.width, height: 50)
                
                let forthElement = MediaElement(text: dateatrStr)
                thirdElement.frame = CGRect(x: 0, y: 150, width: item.size.width, height: 50)
                
                item.add(elements: [firstElement, secondElement, thirdElement, forthElement])
                
                let mediaProcessor = MediaProcessor()
                mediaProcessor.processElements(item: item) { (result, error) in
                    if error != nil {
                        completion(.failure(error!))
                    } else {
                        completion(.success(result.processedUrl!))
                    }
                }
            }
        }
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
        guard let filePath = URL.createFolder(folderName: "temp")?.appendingPathComponent("\(fileName).mp4") else { fatalError("couldnt create file")}
        guard filePath.isFileURL else { fatalError() }
        removeFileAtURLIfExists(url: filePath)
        return filePath
    }
}

extension FileManager {
    class func getFiles() -> ([URL], [String])? {
        // Get the document directory url
        let documentsUrl = URL.createFolder(folderName: "temp")
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl!, includingPropertiesForKeys: nil)
            print(directoryContents)
            
            // if you want to filter the directory contents you can do like this:
            let mp4Files = directoryContents.filter{ $0.pathExtension == "mp4" }
            let mp4FileNames = mp4Files.map{ $0.deletingPathExtension().lastPathComponent }
            return(mp4Files, mp4FileNames)
        } catch {
            print(error)
            return nil
        }
    }
}

extension URL {
    static func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        // Get document directory for device, this should succeed
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first {
            // Construct a URL with desired folder name
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            // If folder URL does not exist, create it
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    // Attempt to create folder
                    try fileManager.createDirectory(atPath: folderURL.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    // Creation failed. Print error & return nil
                    print(error.localizedDescription)
                    return nil
                }
            }
            // Folder either exists, or was created. Return URL
            return folderURL
        }
        // Will only be called if document directory not found
        return nil
    }
}
