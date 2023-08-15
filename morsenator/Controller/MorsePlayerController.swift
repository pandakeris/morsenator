//
//  MorsePlayerController.swift
//  morsenator
//
//  Created by Aaron Christopher Tanhar on 11/08/23.
//

import Foundation
import SwiftUI

class MorsePlayerController: ObservableObject {
    @ObservedObject var morsePlayerModel = MorsePlayerModel.shared
}
