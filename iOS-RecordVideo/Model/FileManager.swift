//
//  FileManager.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 6/21/19.
//  Copyright © 2019 BOTTAK. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import CoreLocation


class FileManagerCreateAndSave: CameraFrameViewController {

    static var instance = FileManagerCreateAndSave()
    
    func createDirectory() {
        let documentPatch = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let logsPatch = documentPatch.appendingPathComponent("temp")
        print(logsPatch!)
        
        do {
            try FileManager.default.createDirectory(atPath: logsPatch!.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Невозможно создать папку",error)
        }
        
    }
    
    func saveImageToDirectory(_ image: UIImage?) {
        let fileManager = FileManager.default
        do {
            let documentPatch = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
            let logsPatch = documentPatch.appendingPathComponent("temp/imageName\(Date().timeIntervalSince1970).png")
            if let imageData = image?.jpegData(compressionQuality: 0.8) {
                try! imageData.write(to: logsPatch!)
            }
            
        }
    }
    
    func saveVideoDirectory(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: AnyObject]) {
        let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as! NSURL
        
        //    let patch = FileManager.default(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        
        let videoData = NSData(contentsOf: videoURL as URL)
        let path = try! FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
        let newPath = path.appendingPathComponent("/videoFileName.mp4")
        do {
            try videoData?.write(to: newPath)
        } catch {
            print(error)
        }
    }
    
    
    func removeFromTempFolder(){
        
        let fileManager = FileManager.default
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let documentsPath = documentsUrl.path
        
        do {
            if let documentPath = documentsPath
            {
                let fileNames = try FileManager.default.contentsOfDirectory(atPath: "\(documentPath)/temp")
                print("all files in cache: \(fileNames)")
                for fileName in fileNames {
                    
                    if (fileName.hasSuffix(".png"))
                    {
                        let filePathName = "\(documentPath)/temp/\(fileName)"
                        try fileManager.removeItem(atPath: filePathName)
                    }
                }
                
                let files = try fileManager.contentsOfDirectory(atPath: "\(documentPath)/temp")
                print("all files in cache after deleting images: \(files)")
            }
            
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
}
