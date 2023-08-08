//
//  Home.swift
//  morsenator
//
//  Created by Aaron Christopher Tanhar on 31/07/23.
//

import SwiftUI

struct ARHome: View {
    var body: some View {
        VStack {
            ARViewControllerContainer().edgesIgnoringSafeArea(.all)
        }
    }
}

struct ARHome_Previews: PreviewProvider {
    static var previews: some View {
        ARHome()
    }
}
