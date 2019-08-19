//
//  VideoPreview.swift
//  iOS-RecordVideo
//
//  Created by Владимир Королев on 03/08/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit
import AVFoundation

public class VideoPreview: UIView {
    public var videoUrl: URL? {
        didSet {
            if let _ = videoUrl {
                self.playerItem = AVPlayerItem.init(url: self.videoUrl! as URL)
            }
        }
    }
    @IBInspectable public var muted: Bool = true {
        didSet {
            self.player.isMuted = self.muted
        }
    }
    public var player: AVPlayer!
    public var playerItem: AVPlayerItem? {
        didSet {
            if let playerItem = self.playerItem {
                player = AVPlayer(playerItem: playerItem)
                player.actionAtItemEnd = .none
                self.player.isMuted = self.muted
                NotificationCenter.default.removeObserver(self)
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(playerItemDidReachEnd(notification:)),
                                                       name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                       object: playerItem)
                self.playerLayer.player = self.player
                self.player.play()
                self.layoutSubviews()
            }
        }
    }
    public let playerLayer: AVPlayerLayer = AVPlayerLayer.init()
    
    // MARK:- View Lifecycle
    
    override public init(frame: CGRect) {
        super.init(frame: frame);
        
        {
            self.setup()
        }()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        {
            self.setup()
        }()
    }
    
    public init(videoUrl: URL) {
        self.init();
        
        {
            self.videoUrl = videoUrl;
        }()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        // update AVPlayerLayer frame when VideoLoopView has been resized
        var newFrame = self.frame
        newFrame.origin = CGPoint(x: 0, y: 0)
        self.playerLayer.frame = newFrame
        self.playerLayer.removeFromSuperlayer()
        self.layer.addSublayer(self.playerLayer)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setup() {
        self.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    }
    
    // MARK:- Controls
    
    @objc public func playVideo() {
        self.player.play()
    }
    
    @objc public func pauseVideo() {
        self.player.pause()
    }
    
    // MARK:- NSNotification
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        let playerItem = notification.object as! AVPlayerItem
        playerItem.seek(to: Date(), completionHandler: nil)
    }
}
