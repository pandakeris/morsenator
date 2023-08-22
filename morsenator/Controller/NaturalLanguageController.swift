//
//  NaturalLanguageController.swift
//  morsenator
//
//  Created by Aaron Christopher Tanhar on 22/08/23.
//

import Foundation
import NaturalLanguage

class NLController: ObservableObject {
    let languageRecognizer = NLLanguageRecognizer()

    func recognizeLanguage(_ text: String) -> NLLanguage? {
        languageRecognizer.reset()
        languageRecognizer.processString(text)
        return languageRecognizer.dominantLanguage
    }
}
