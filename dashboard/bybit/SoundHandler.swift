//
//  SoundHandler.swift
//  dashboard
//
//  Created by km on 23/01/2024.
//

import Foundation
import SwiftySound

class SoundHandler {
    static let shared = SoundHandler()
    @Published var isSoundPLaying: Bool = false
    @Published var muted: Bool = true
    
    let mySound = Sound(url: Bundle.main.url(forResource: "piano", withExtension: "mp3")!)
    
    func stopAll() {
        mySound?.stop()
    }

    func mute() {
        muted = true
        stopAll()
    }
    func unmute() {
        muted  = false
    }
    
    func playSound() {
        if !isSoundPLaying && !muted {
            isSoundPLaying = true
            mySound!.play { _ in
                self.isSoundPLaying = false
            }
        }
    }
}
