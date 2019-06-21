//
//  ViewController.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 6/19/19.
//  Copyright © 2019 BOTTAK. All rights reserved.
//

import UIKit
import UIKit
import AVKit
import MobileCoreServices

class RecordVideoViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate {


    
    //MARK: - Outlets
    
    
    @IBOutlet weak var recordVideoButtonDidTap: UIButton!
    
    var videoAndImageReview = UIImagePickerController()
    var videoURL: URL?
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presentCamera()
    }
    
    func presentCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            print("Камера готова")
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            print("Камера не готова")
        }
    }
    //MARK: - Actions

    @IBAction func recordVideoButtonTapped(_ sender: Any) {
        presentCamera()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        guard
            let mediaType = info[.mediaType] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[.mediaURL] as? URL,
            UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
            else {
                return
        }
        
        // Handle a movie capture
        UISaveVideoAtPathToSavedPhotosAlbum(
            url.path,
            self,
            #selector(video(_:didFinishSavingWithError:contextInfo:)),
            nil)
    }
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        let title = (error == nil) ? "Успешно" : "Ошибка"
        let message = (error == nil) ? "Видео сохранено" : "Видео не сохранено"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    

    
    @IBAction func playVideoButtonTapped(_ sender: Any) {
        videoAndImageReview.sourceType = .photoLibrary
        videoAndImageReview.delegate = self
        videoAndImageReview.mediaTypes = ["public.movie"]
        present(videoAndImageReview, animated: true, completion: nil)
    }
    

    func videoAndImageReview(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        videoURL = info[.mediaURL] as? URL
        print("videoURL:\(String(describing: videoURL))")
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

