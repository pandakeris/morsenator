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
import Combine
import SwiftUI

// ViewOnly
struct MorseMainView: View {
    enum FocusedField {
        case morse, text
    }

    @State private var morseCodeInput: String = ""
    @State private var textInput: String = ""
    @FocusState private var focusedField: FocusedField?
    @EnvironmentObject var morsePlayerController: MorsePlayerController
    @EnvironmentObject var speechController: SpeechController
    @EnvironmentObject var hapticController: HapticController
    @EnvironmentObject var nlController: NLController
    @State private var task: Task<Void, Never>?
    @State private var isCopied: Bool = false

    var body: some View {
        VStack {
            Text("Morse Code to Sound")
                .font(.title)
                .padding()

            HStack {
                TextField("Enter Morse Code", text: $morseCodeInput)
                    .focused($focusedField, equals: .morse)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                    .onReceive(Just(morseCodeInput)) { newValue in
                        let allowedCharacters = ".- …—"
                        let filtered = newValue.filter { allowedCharacters.contains($0) }
                        if filtered != newValue {
                            self.morseCodeInput = filtered
                        }
                        self.textInput = morse2Words(morse: morseCodeInput)
                    }
                Button {
                    let clipboard = UIPasteboard.general
                    clipboard.setValue(morseCodeInput, forPasteboardType: UTType.plainText.identifier)
                    isCopied = true
                    DispatchQueue.main.asyncAfter(wallDeadline: .now() + 3) {
                        isCopied = false
                    }
                } label: {
                    Image(systemName: "clipboard")
                }.buttonStyle(IconButton(width: 30, height: 30))
            }
            HStack {
                if focusedField == .morse {
                    TextField("Enter Text", text: $textInput)
                        .focused($focusedField, equals: .text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding()
                } else {
                    TextField("Enter Text", text: $textInput)
                        .focused($focusedField, equals: .text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding()
                        .onReceive(Just(textInput)) { newValue in
                            if textInput != newValue {
                                textInput = newValue
                            }
                            morseCodeInput = word2Morse(words: textInput)
                        }
                }
                Button {
                    let clipboard = UIPasteboard.general
                    clipboard.setValue(textInput, forPasteboardType: UTType.plainText.identifier)
                    isCopied = true
                    DispatchQueue.main.asyncAfter(wallDeadline: .now() + 3) {
                        isCopied = false
                    }
                } label: {
                    Image(systemName: "clipboard")
                }.buttonStyle(IconButton(width: 30, height: 30))
            }

            if isCopied {
                // Shows up only when copy is done
                Text("Copied successfully!")
                    .foregroundColor(.white)
                    .bold()
                    .font(.footnote)
                    .frame(width: 140, height: 30)
                    .background(Color.indigo.cornerRadius(7))
            }

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
                speechController.playSpeech(text: morse2Words(morse: morseCodeInput.replacingOccurrences(of: "—", with: "--").replacingOccurrences(of: "…", with: "...")), lang: nlController.recognizeLanguage(textInput)?.rawValue ?? "en-US")
            } label: {
                Text("Play Text")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            Text(nlController.recognizeLanguage(textInput)?.rawValue ?? "")
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
