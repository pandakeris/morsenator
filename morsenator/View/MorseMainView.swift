//
//  MorseMainView.swift
//  T2S
//
//  Created by Timothyus Kevin Dewanto on 08/08/23.
//

import AVFAudio
import AVFoundation
import AVKit
import AVRouting
import SwiftUI

struct MorseCodeApp: App {
    var body: some Scene {
        WindowGroup {
            MorseMainView()
        }
    }
}

// ViewOnly
struct MorseMainView: View {
    @State private var morseCodeInput: String = ""
    private var morsePlayer = MorseCodePlayer()

    var body: some View {
        VStack {
            Text("Morse Code to Sound")
                .font(.title)
                .padding()

            TextField("Enter Morse Code", text: $morseCodeInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding()

            Button(action: {
                morsePlayer.playMorseCode(morseCodeInput.replacingOccurrences(of: "—", with: "--").replacingOccurrences(of: "…", with: "..."))
            }) {
                Text("Play Morse Code")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

// The Whole Function
class MorseCodePlayer {
    let dotDuration: TimeInterval = 0.1
    let dashDuration: TimeInterval = 1.0
    let wordGapDuration: TimeInterval = 1.0
    let letterGapDuration: TimeInterval = 1.5
    var audioPlayer: AVAudioPlayer?

    init() {
        if let soundURL = Bundle.main.url(forResource: "morsesound", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error loading sound file: \(error)")
            }
        }
    }

    func playMorseCode(_ morseCode: String) {
        for character in morseCode {
            switch character {
            case ".":
                playSound(duration: dotDuration)
            case "-":
                playSound(duration: dashDuration)
            case " ":
                pause(duration: letterGapDuration)
            default:
                break
            }
        }
        pause(duration: wordGapDuration)
    }

    private func playSound(duration: TimeInterval) {
        audioPlayer?.play()
        Thread.sleep(forTimeInterval: duration)
        audioPlayer?.stop()
    }

    private func pause(duration: TimeInterval) {
        Thread.sleep(forTimeInterval: duration)
    }
}

struct MorseMainView_Previews: PreviewProvider {
    static var previews: some View {
        MorseMainView()
    }
}
