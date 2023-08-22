//
//  SpeechController.swift
//  morsenator
//
//  Created by Aaron Christopher Tanhar on 21/08/23.
//

import AVFoundation
import Foundation
import NaturalLanguage
import SwiftUI

class SpeechController: ObservableObject {
    let synthesizer = AVSpeechSynthesizer()

    func playSpeech(text: String, lang: String = "en-US") {
        print(text)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: lang)

        synthesizer.speak(utterance)
    }
}
