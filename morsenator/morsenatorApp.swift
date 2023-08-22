//
//  morsenatorApp.swift
//  morsenator
//
//  Created by Timothyus Kevin Dewanto on 31/07/23.
//

import SwiftUI

extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}

@main
struct morsenatorApp: App {
    @StateObject private var timerController = TimerController()
    @StateObject private var morsePlayerController = MorsePlayerController()
    @StateObject private var speechController = SpeechController()
    @StateObject private var arMorseModel = ARMorseModel()
    @StateObject private var motionModel = MotionModel()
    @StateObject private var hapticController = HapticController()
    @StateObject private var nlController = NLController()
    @StateObject private var dataController = DataController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timerController)
                .environmentObject(morsePlayerController)
                .environmentObject(arMorseModel)
                .environmentObject(speechController)
                .environmentObject(motionModel)
                .environmentObject(hapticController)
                .environmentObject(nlController)
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
