//
//  Sound.swift
//  iOS-RecordVideo
//
//  Created by BOTTAK on 8/29/19.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import Foundation
import AudioToolbox

enum SoundExtension : String{
    case caf
    case aif
    case wav
}

let  shortRing = "reload4"

class Sound {
    
    var notificationSoundLookupTable = [String: SystemSoundID]()
    var shouldPlaySoundEffects = true
    
    
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

