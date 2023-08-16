//
//  Home.swift
//  morsenator
//
//  Created by Aaron Christopher Tanhar on 31/07/23.
//

import SwiftUI

struct ARHome: View {
    @EnvironmentObject var arMorseModel: ARMorseModel

    var body: some View {
        VStack {
            #if !targetEnvironment(simulator)
                ARViewControllerContainer().edgesIgnoringSafeArea(.all).environmentObject(arMorseModel)
                Text(arMorseModel.morseText)
                Text(arMorseModel.text)
            #endif
        }.onChange(of: arMorseModel.morseText) { newValue in
            arMorseModel.text = morse2Words(morse: newValue)
        }
    }
}

struct ARHome_Previews: PreviewProvider {
    static var previews: some View {
        ARHome()
    }
}
