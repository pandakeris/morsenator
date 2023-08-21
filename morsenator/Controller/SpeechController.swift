//
//  SpeechController.swift
//  morsenator
//
//  Created by Aaron Christopher Tanhar on 21/08/23.
//

import Foundation
import SwiftUI
import AVFoundation
import NaturalLanguage

class SpeechController: ObservableObject {
    let synthesizer = AVSpeechSynthesizer()
    
    func playSpeech(text: String) {
        print(text)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")

        self.synthesizer.speak(utterance)
    }
}
