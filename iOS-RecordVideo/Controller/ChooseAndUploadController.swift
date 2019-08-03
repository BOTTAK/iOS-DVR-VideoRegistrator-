//
//  ChooseAndUploadController.swift
//  iOS-RecordVideo
//
//  Created by Владимир Королев on 03/08/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit
import AVFoundation

class ChooseAndUploadController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let networkingManager = NetworkingManager()
    
    var fileNames: [String] {
        guard let names = FileManager.getFiles()?.1 else { return [] }
        return names
    }
    
    var fileURLs: [URL] {
        guard let urls = FileManager.getFiles()?.0 else { return [] }
        return urls
    }
    
    var choosenFile: URL?

    @IBOutlet weak var videoPreviewView: VideoPreview!
    @IBOutlet weak var videoListTableView: UITableView!
    @IBOutlet weak var uploadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        videoListTableView.delegate = self
        videoListTableView.dataSource = self
        networkingManager.authorisation { token in
            self.networkingManager.token = token
        }
    }
    
    @IBAction func uploadPress(_ sender: UIButton) {
        guard let urlToUpload = choosenFile else {
            UIHelper.showError(errorMessage: "You must choose file to upload.", controller: self)
            return
        }
        prepareFile(url: urlToUpload)
    }
    
    func prepareFile(url: URL) {
        let asset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        
        guard let metadata = asset.metadata.first?.value else { fatalError() }
        let newMetadata = String(metadata as! Substring)
        
        let parsedMetaDataArray = newMetadata.components(separatedBy: "+")
        
        networkingManager.uploadVideo(videoUrl: url, metadata: parsedMetaDataArray) { result in
            switch result {
            case let .success(value):
                print(value as Any)
            case let .failure(error):
                UIHelper.showError(errorMessage: error.localizedDescription, controller: self)
            }
        }
    }
    
}

extension ChooseAndUploadController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileNames.count  
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath)
        cell.textLabel?.text = fileNames[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosenFile = fileURLs[indexPath.row]
        videoPreviewView.videoUrl = choosenFile
    }
}
