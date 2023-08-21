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

// ViewOnly
struct MorseMainView: View {
    @State private var morseCodeInput: String = ""
    @EnvironmentObject var morsePlayerController: MorsePlayerController
    @EnvironmentObject var speechController: SpeechController
    @State private var task: Task<Void, Never>?

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
                task?.cancel()
                task = Task {
                    await morsePlayerController.morsePlayerModel.playMorseCode(morseCodeInput.replacingOccurrences(of: "—", with: "--").replacingOccurrences(of: "…", with: "..."))
                }
            }) {
                Text("Play Morse Code")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            Button {
                speechController.playSpeech(text: morse2Words(morse: morseCodeInput.replacingOccurrences(of: "—", with: "--").replacingOccurrences(of: "…", with: "...")) )
            } label: {
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

struct MorseMainView_Previews: PreviewProvider {
    static var previews: some View {
        MorseMainView()
    }
}
