//
//  ImageUploadViewController.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 7/29/19.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ImageUploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let networkingManager = NetworkingManager()
    
    //MARK: - Outlets
    
    @IBOutlet weak var imageViewUpload: UIImageView!
    @IBOutlet weak var progressUploadToServer: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    
    //MARK: - Action
    
    @IBAction func uploadButtonToServer(_ sender: Any) {
//
        let imagePicker = UIImagePickerController()

        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.movie"]

        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkingManager.authorisation { [weak self] token in
            self?.networkingManager.token = token
        }
        
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    print("OK")
                } else {}
            })
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let fileURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { fatalError() }
        guard let metadata = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset else { fatalError() }
        guard let location = metadata.location else { fatalError() }
        
        guard fileURL.isFileURL else { fatalError() }
        
        let asset = AVURLAsset(url: fileURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        
        guard let exportSession = AVAssetExportSession(asset: asset,
                                                       presetName: AVAssetExportPresetPassthrough) else { fatalError() }
        exportSession.outputFileType = .mp4
        FileManager.removeFileAtURLIfExists(url: FileManager.createNewFilePath(fileName: "secondTry"))
        exportSession.outputURL = FileManager.createNewFilePath(fileName: "secondTry")
        
        exportSession.exportAsynchronously(completionHandler: {() -> Void in
            switch exportSession.status {
            case .failed:
                print(exportSession.error ?? "No error")
            case .cancelled:
                print("Export cancelled")
            case .completed:
                guard let correctURL = exportSession.outputURL else {
                    print("error getting url")
                    return
                }
                print("Successful! \(correctURL)")
                print(correctURL.pathExtension)
                self.networkingManager.uploadVideo(videoUrl: correctURL, location: location) { (result: Result<Any, Error>) in
                    switch result {
                    case let .success(value):
                        print(value as Any)
                        self.dismiss(animated: true, completion: nil)
                        self.dismiss(animated: true, completion: nil)
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                }
            default:
                fatalError()
            }
        })
    }
    
    func uploadImage() {
        
        let image = UIImage()
        let imageDataSource = image.jpegData(compressionQuality: 1)
        
        if (imageDataSource == nil) { return
            
        }
        
        self.uploadButton.isEnabled = false
        
        let uploadScriptUrl = NSURL(string: "http://www.swiftdeveloperblog.com/http-post-example-script/")
        let request = NSMutableURLRequest(url: uploadScriptUrl! as URL)
        request.httpMethod = "POST"
        request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self as? URLSessionDelegate, delegateQueue: OperationQueue.main)
        
        let task = session.uploadTask(with: request as URLRequest, from: imageDataSource!)
        task.resume()
        
        
    }

    func URLSessionTwo(session: URLSession, task: URLSessionTask, didCpmpleteWithError error: NSError?) {
        
        let myAlert = UIAlertView(title: "Alert", message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "Ok")
        myAlert.show()
        self.uploadButton.isEnabled = true
    }
    
    func URLSessionTree(session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedSend: Int64) {
        
        let uploadProgress: Float = Float(totalBytesSent) / Float(totalBytesExpectedSend)
        
        progressUploadToServer.progress = uploadProgress
        let profressPercent = Int(uploadProgress*100)
        progressLabel.text = "\(profressPercent)%"
    }
    
    func URLSessionFour(session: URLSession, dataTask: URLSessionTask, didReceiveResponse response: URLResponse, complitionHandler: (URLSessionUploadTask) -> Void) {
        
        self.uploadButton.isEnabled = true
        
    }
    
}
