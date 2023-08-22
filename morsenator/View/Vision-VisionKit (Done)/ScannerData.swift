//
//  ScannerData.swift
//  morsenator
//
//  Created by Timothyus Kevin Dewanto on 02/08/23.
//

import SwiftUI

struct ScannerData: Identifiable {
    var id = UUID()
    let content: String
    init(content: String) {
        self.content = content
    }
}
