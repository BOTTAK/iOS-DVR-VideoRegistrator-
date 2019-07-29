//
//  ImageUploadViewController.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 7/29/19.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit
import AVFoundation

class ImageUploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    //MARK: - Outlets
    
    @IBOutlet weak var imageViewUpload: UIImageView!
    @IBOutlet weak var progressUploadToServer: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    
    //MARK: - Action
    
    @IBAction func uploadButtonToServer(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
       
        
        imagePicker.delegate = self 
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

        func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaInfo info: [UIImagePickerController.InfoKey : AnyObject]) {
        imageViewUpload.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageViewUpload.backgroundColor = UIColor.clear
            self.dismiss(animated: true, completion: nil)
            uploadImage()
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
