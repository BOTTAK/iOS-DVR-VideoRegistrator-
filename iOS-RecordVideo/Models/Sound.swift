//
//  Sound.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 8/29/19.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import Foundation
import AudioToolbox
import AVFoundation

enum SoundExtension : String{
    case caf
    case aif
    case wav
}





class Sound {
    
    
    //MARK: - Outlets
    let  shortRing = "reload4"
    var notificationSoundLookupTable = [String: SystemSoundID]()
    var shouldPlaySoundEffects = true
    var audioPlayer: AVPlayer?
    var bombSoundEffect: AVAudioPlayer?
    
    
    //MARK: - Play function
    
    func playNotificationSound() {
        guard let soundURL = Bundle.main.url(forResource: "reload4", withExtension: "wav") else { return }
        audioPlayer = AVPlayer(url: soundURL as URL)
        audioPlayer?.play()
    }
    
    func prepareAudio() {
        let path = Bundle.main.path(forResource: "reload4", ofType: "wav")
        let url = URL(fileURLWithPath: path!)
        do {
            bombSoundEffect = try? AVAudioPlayer(contentsOf: url)
            bombSoundEffect?.play()
        } catch {
            print("error \(error)")
        }
    }
    
    func playSound() {
        play(sound: shortRing, ofType: .wav)
    }
    
    func play(sound: String, ofType type: SoundExtension) {
        if let soundID = notificationSoundLookupTable[sound] {
            AudioServicesPlaySystemSound(soundID)
        } else {
            if let soundURL : CFURL = Bundle.main.url(forResource: sound, withExtension: type.rawValue) as CFURL? {
                var soundID  : SystemSoundID = 0
                let osStatus : OSStatus = AudioServicesCreateSystemSoundID(soundURL, &soundID)
                if osStatus == kAudioServicesNoError {
                    AudioServicesPlaySystemSound(soundID);
                    notificationSoundLookupTable[sound] = (soundID)
                }else{
                    
                }
            }
        }
    }
    
    func plafy(sound: String, ofType type: SoundExtension) {
        if let soundID = notificationSoundLookupTable[sound] {
            AudioServicesPlaySystemSound(soundID)
        } else {
            if let soundURL : CFURL = Bundle.main.url(forResource: sound,       withExtension: type.rawValue) as CFURL? {
                var soundID  : SystemSoundID = 0
                let osStatus : OSStatus = AudioServicesCreateSystemSoundID(soundURL, &soundID)
                if osStatus == kAudioServicesNoError {
                    AudioServicesPlaySystemSound(soundID);
                    notificationSoundLookupTable[sound] = (soundID)
                }else{
                   
                }
            }
        }
    }
    
    func disposeSoundIDs() {
        for soundID in notificationSoundLookupTable.values {
            AudioServicesDisposeSystemSoundID(soundID)
        }
    }
    
    
    deinit {
        self.disposeSoundIDs()
    }
    
    
    
}

