//
//  ScannerData.swift
//  morsenator
//
//  Created by Timothyus Kevin Dewanto on 02/08/23.
//

import SwiftUI

struct ScannerData:Identifiable{
    var id = UUID()
    let content: String
    init(content:String){
        self.content = content
    }
}

//What if I want to use other thing such as flashing light
//Or perhaps using sound to translate the morse code?
//AVFoundation needs to be learned by now, I guess...
