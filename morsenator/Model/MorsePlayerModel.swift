//
//  MorsePlayerModel.swift
//  morsenator
//
//  Created by Aaron Christopher Tanhar on 11/08/23.
//

import AVFAudio
import AVFoundation
import AVKit
import AVRouting
import Foundation
import SwiftUI

// The Whole Function
class MorsePlayerModel: ObservableObject {
    public static var shared: MorsePlayerModel = .init()
    var hapticController: HapticController = .init()
    let dotDuration: TimeInterval = 0.2
    let dashDuration: TimeInterval = 0.5
    let wordGapDuration: TimeInterval = 1.0
    let letterGapDuration: TimeInterval = 0.5
    var audioPlayer: AVAudioPlayer?
    var soundURL: URL?

    init() {
        if let soundURL = Bundle.main.url(forResource: "morsesound", withExtension: "mp3") {
            self.soundURL = soundURL
        }
    }

    func reloadAudioPlayer() {
        if audioPlayer != nil {
            audioPlayer?.stop()
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
            if audioPlayer != nil {
                audioPlayer!.numberOfLoops = 1
            }
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error loading sound file: \(error)")
        }
    }

    func playMorseCode(_ morseCode: String) async {
        reloadAudioPlayer()
        for character in morseCode {
            switch character {
            case ".":
                await playSound(duration: dotDuration)
                await pause(duration: letterGapDuration)
            case "-":
                await playSound(duration: dashDuration)
                await pause(duration: letterGapDuration)
            case " ":
                await pause(duration: wordGapDuration)
            default:
                break
            }
        }
        stop()
    }

    private func playSound(duration: TimeInterval) async {
        audioPlayer?.play()
        hapticController.vibrate(duration: duration)
        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
        audioPlayer?.stop()
        reloadAudioPlayer()
    }

    private func pause(duration: TimeInterval) async {
        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
    }

    private func stop() {
        audioPlayer?.stop()
        reloadAudioPlayer()
    }
}
