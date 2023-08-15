//
//  ARMorseModel.swift
//  morsenator
//
//  Created by Aaron Christopher Tanhar on 15/08/23.
//

import Foundation
import SwiftUI

// The Whole Function
class ARMorseModel: ObservableObject {
    public static var shared: ARMorseModel = .init()

    var morseText = ""
    var text = ""

    func setText(text: String) {
        self.text = text
    }

    func setMorseText(text: String) {
        morseText = text
    }
}
