//
//  Home.swift
//  morsenator
//
//  Created by Aaron Christopher Tanhar on 31/07/23.
//

import SwiftUI

struct Home: View {
    var body: some View {
        VStack {
            ARViewControllerContainer().edgesIgnoringSafeArea(.all)
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
