//
//  FileManagerViewController.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 6/21/19.
//  Copyright © 2019 BOTTAK. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class FileManagerWithVideo: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var videoAndImageReview = UIImagePickerController()
    var videoURL: URL?
    
    @IBAction func playVideoFromLibraryButton(_ sender: Any) {
        videoAndImageReview.sourceType = .photoLibrary
        videoAndImageReview.delegate = self
        videoAndImageReview.mediaTypes = ["public.movie"]
        present(videoAndImageReview, animated: true, completion: nil)
    }
    
    
    
    @IBAction func videoAndImagePreview(_ sender: Any) {
    }
    
    
    func videoAndImageReview(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        videoURL = info[.mediaURL] as? URL
        print("videoURL:\(String(describing: videoURL))")
        self.dismiss(animated: true, completion: nil)
    }
    
}
    
    
