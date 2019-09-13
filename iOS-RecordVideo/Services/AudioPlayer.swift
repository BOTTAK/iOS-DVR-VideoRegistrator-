//
//  AudioPlayer.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 9/12/19.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import AVFoundation

class AudioPlayer: NSObject {
    public static let shared = AudioPlayer()
    
    private var audioPlayer: AVAudioPlayer?
    
    func playSound(_ soundName: String) {
        let url = Bundle.main.url(forResource: soundName, withExtension: "wav")!
        let player = try! AVAudioPlayer(contentsOf: url)
        player.delegate = self
        self.audioPlayer = player
        player.play()
    }
    func playSound(_ sound: Sound) {
        let stringValue = sound.rawValue
        self.playSound(stringValue)
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.audioPlayer = nil
    }
}

extension AudioPlayer {
    enum Sound: String {
        case reload = "reload4"
        case notification = "notification 1"
    }
}
