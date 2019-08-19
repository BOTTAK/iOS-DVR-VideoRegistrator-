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
    
    func trimVideo(sourceURL: URL, duration: Double, metaData: [String], completion: @escaping (Result<URL, Error>)->Void) {
        
        guard sourceURL.isFileURL else { fatalError() }
        
        let asset = AVURLAsset(url: sourceURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        if asset.duration.seconds < duration {
            completion(.failure(NSError(domain: "Video", code: 1056, userInfo: [NSLocalizedDescriptionKey : "Cannot create video with \(Int(duration)) sec duration because it is not recorded yet"])))
            return
        }
        guard let exportSession = AVAssetExportSession(asset: asset,
                                                       presetName: AVAssetExportPresetPassthrough) else { fatalError() }
        
        exportSession.timeRange = generateRange(startTime: asset.duration.seconds - duration,
                                                endTime: asset.duration.seconds)
        exportSession.outputURL = FileManager.createNewFilePath(fileName: videoName)
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        exportSession.exportAsynchronously(completionHandler: {() -> Void in
            switch exportSession.status {
            case .failed:
                print(exportSession.error ?? "No error")
                completion(.failure(exportSession.error!))
            case .cancelled:
                let error = NSError(domain: "VideoApp", code: 00, userInfo: ["Message": "Export cancelled"])
                completion(.failure(error))
            case .completed:
                guard let correctURL = exportSession.outputURL
                else {
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
