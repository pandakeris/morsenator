//
//  Word2Morse.swift
//  M2P
//
//  Created by Timothyus Kevin Dewanto on 14/08/23.
//

import SwiftUI

struct Word2Morse: View {
    @State private var inputText = ""
    @State private var translatedText = ""
    @State private var isTranslatingToMorse = true

    var body: some View {
        VStack {
            TextField("Enter text or Morse code", text: $inputText, axis: .vertical)
                .foregroundColor(.white)
                .frame(minWidth: 100, maxHeight: 200)
                .lineLimit(5 ... 10)
                .padding()
                .background(.blue)
                .padding()

            Toggle("Translate to Morse", isOn: $isTranslatingToMorse)
                .padding()

            Button(action: translate) {
                Text("Translate")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Text("Result:")
                .font(.title2)
                .padding()

            Text(translatedText)
                .font(.subheadline)
                .padding()
        }
        Spacer()
    }

    func translate() {
        if isTranslatingToMorse {
            translatedText = word2Morse(words: inputText)
        } else {
            translatedText = morse2Words(morse: inputText.replacingOccurrences(of: "—", with: "--").replacingOccurrences(of: "…", with: "..."))
        }
    }
}

struct Word2Morse_Previews: PreviewProvider {
    static var previews: some View {
        Word2Morse()
    }
}
