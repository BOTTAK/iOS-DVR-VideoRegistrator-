//
//  ChooseAndUploadController.swift
//  iOS-RecordVideo
//
//  Created by Владимир Королев on 03/08/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit

class ChooseAndUploadController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var videoPreviewView: UIView!
    @IBOutlet weak var videoListTableView: UITableView!
    @IBOutlet weak var uploadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
}

extension ChooseAndUploadController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
