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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
