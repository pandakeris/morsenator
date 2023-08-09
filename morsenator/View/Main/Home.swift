//
//  Home.swift
//  morsenator
//
//  Created by Aaron Christopher Tanhar on 07/08/23.
//

import SwiftUI

struct Home: View {
    @State private var animateGradient = false

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Image("Logo")
                    NavigationLink {
                        ARHome()
                    } label: {
                        Label("AR", systemImage: "play.circle")
                    }.buttonStyle(MainButton(width: UIDevice.isIPad ? 400 : 200, height: UIDevice.isIPad ? 75 : 35)).font(UIDevice.isIPad ? .largeTitle : .title2).padding()
                    NavigationLink {
                        MainView()
                    } label: {
                        Label("Vision", systemImage: "questionmark.circle")
                    }.buttonStyle(MainButton(width: UIDevice.isIPad ? 400 : 200, height: UIDevice.isIPad ? 75 : 35)).font(UIDevice.isIPad ? .largeTitle : .title2).padding()
                    NavigationLink {
                        MorseMainView()
                    } label: {
                        Label("AVFoundation", systemImage: "questionmark.circle")
                    }.buttonStyle(MainButton(width: UIDevice.isIPad ? 400 : 200, height: UIDevice.isIPad ? 75 : 35)).font(UIDevice.isIPad ? .largeTitle : .title2).padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // 1
            .background(
                LinearGradient(colors: [Color("Blue"), .yellow], startPoint: animateGradient ? .topLeading : .bottomLeading, endPoint: animateGradient ? .bottomTrailing : .topTrailing)
                    .ignoresSafeArea()
                    .hueRotation(.degrees(animateGradient ? 45 : 0))
                    .onAppear {
                        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: true)) {
                            animateGradient.toggle()
                        }
                    }
            )
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
