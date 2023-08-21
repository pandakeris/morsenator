//
//  Morse.swift
//  morsenator
//
//  Created by Aaron Christopher Tanhar on 07/08/23.
//

import Foundation

extension Dictionary where Value: Hashable {
    func swapKeyValues() -> [Value: Key] {
        assert(Set(values).count == keys.count, "Values must be unique")
        var newDict = [Value: Key]()
        for (key, value) in self {
            newDict[value] = key
        }
        return newDict
    }
}

let MORSE_CODE = [
    "0": "-----",
    "1": ".----",
    "2": "..---",
    "3": "...--",
    "4": "....-",
    "5": ".....",
    "6": "-....",
    "7": "--...",
    "8": "---..",
    "9": "----.",
    "a": ".-",
    "b": "-...",
    "c": "-.-.",
    "d": "-..",
    "e": ".",
    "f": "..-.",
    "g": "--.",
    "h": "....",
    "i": "..",
    "j": ".---",
    "k": "-.-",
    "l": ".-..",
    "m": "--",
    "n": "-.",
    "o": "---",
    "p": ".--.",
    "q": "--.-",
    "r": ".-.",
    "s": "...",
    "t": "-",
    "u": "..-",
    "v": "...-",
    "w": ".--",
    "x": "-..-",
    "y": "-.--",
    "z": "--..",
    ".": ".-.-.-",
    ",": "--..--",
    "?": "..--..",
    "!": "-.-.--",
    "-": "-....-",
    "/": "-..-.",
    "@": ".--.-.",
    "(": "-.--.",
    ")": "-.--.-"
]

let MORSE_CODE_REVERSE = MORSE_CODE.swapKeyValues()

func word2Morse(words: String) -> String {
    let wordArr = words.map { word -> String in
        MORSE_CODE.contains { $0.key == String(word.lowercased()) } ? MORSE_CODE[String(word.lowercased())]! : String(word)
    }

    return wordArr.joined(separator: " ")
}

func morse2Word(_ rawMorse: String) -> String {
    let morse = rawMorse.replacingOccurrences(of: "—", with: "--").replacingOccurrences(of: "…", with: "...")
    let morseArr = morse.components(separatedBy: [" "]).map { word -> String in
        MORSE_CODE_REVERSE.contains { $0.key == word } ? MORSE_CODE_REVERSE[word]! : ""
    }

    return morseArr.joined(separator: "")
}

func morse2Words(morse: String) -> String {
    let morseArr = morse.components(separatedBy: "   ").map { word -> String in
        morse2Word(word)
    }

    return morseArr.joined(separator: " ")
}
