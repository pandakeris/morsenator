//
//  Home.swift
//  morsenator
//
//  Created by Aaron Christopher Tanhar on 31/07/23.
//

import SwiftUI

struct ARHome: View {
    @EnvironmentObject var arMorseModel: ARMorseModel
    @EnvironmentObject var speechController: SpeechController

    var body: some View {
        VStack {
            #if !targetEnvironment(simulator)
                ARViewControllerContainer().edgesIgnoringSafeArea(.all).environmentObject(arMorseModel)
                Text(arMorseModel.morseText)
                Text(arMorseModel.text)
                HStack {
                    Button {
                        speechController.playSpeech(text: arMorseModel.text)
                    } label: {
                        Label("Play", systemImage: "play.circle")
                    }
                    Button {
                        arMorseModel.text = ""
                        arMorseModel.morseText = ""
                        arMorseModel.objectWillChange.send()
                    } label: {
                        Label("Clear", systemImage: "xmark.circle")
                    }
                }
            #endif
        }.onChange(of: arMorseModel.morseText) { newValue in
            arMorseModel.text = morse2Words(morse: newValue)
            arMorseModel.objectWillChange.send()
        }
    }
}

struct ARHome_Previews: PreviewProvider {
    static var previews: some View {
        ARHome()
    }
}
