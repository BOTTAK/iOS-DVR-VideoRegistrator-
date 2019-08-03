//
//  ChooseAndUploadController.swift
//  iOS-RecordVideo
//
//  Created by Владимир Королев on 03/08/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit

class ChooseAndUploadController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
