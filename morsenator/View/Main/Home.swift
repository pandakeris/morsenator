//
//  Home.swift
//  morsenator
//
//  Created by Aaron Christopher Tanhar on 07/08/23.
//

import CoreHaptics
import SwiftUI

struct Home: View {
    @State private var animateGradient = false
    @EnvironmentObject var motionModel: MotionModel
    @EnvironmentObject var timerController: TimerController
    @State private var roll = false
    @State private var pitch = false
    @State private var animatePosition = false

    let maxRad = 3.14159

    func updateMotion() {
        roll = motionModel.getAttitude()?.roll ?? 0 > 0
        pitch = motionModel.getAttitude()?.pitch ?? 0 > 0
    }

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Image("Logo").resizable().frame(width: 200, height: 200)
                    NavigationLink {
                        #if !targetEnvironment(simulator)
                            ARHome()
                        #endif
                    } label: {
                        #if !targetEnvironment(simulator)
                            Label("AR", systemImage: "play.circle")
                        #else
                            Label("AR (disabled on simulator)", systemImage: "play.circle")
                        #endif
                    }.buttonStyle(MainButton(width: UIDevice.isIPad ? 400 : 200, height: UIDevice.isIPad ? 75 : 35)).font(UIDevice.isIPad ? .largeTitle : .title2).padding()
                    NavigationLink {
                        MainView()
                    } label: {
                        Label("Vision", systemImage: "eye.circle")
                    }.buttonStyle(MainButton(width: UIDevice.isIPad ? 400 : 200, height: UIDevice.isIPad ? 75 : 35)).font(UIDevice.isIPad ? .largeTitle : .title2).padding()
                    NavigationLink {
                        MorseMainView()
                    } label: {
                        Label("AVFoundation", systemImage: "speaker.wave.2.circle")
                    }.buttonStyle(MainButton(width: UIDevice.isIPad ? 400 : 200, height: UIDevice.isIPad ? 75 : 35)).font(UIDevice.isIPad ? .largeTitle : .title2).padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // 1
            .background(
                LinearGradient(colors: [.black, .green], startPoint: animatePosition ? .topLeading : .bottomLeading, endPoint: animatePosition ? .bottomTrailing : .topTrailing)
                    .ignoresSafeArea()
                    .hueRotation(.degrees(animateGradient ? 45 : 0))
                    .onAppear {
                        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: true)) {
                            animateGradient.toggle()
                        }
                    }
            )
        }.navigationViewStyle(StackNavigationViewStyle())
            .onAppear {
                motionModel.startUpdates()
                timerController.setTimer(key: "statTimer", withInterval: 0.1) {
                    let oldPitch = pitch
                    updateMotion()
                    if pitch != oldPitch {
                        withAnimation(.linear(duration: 2.0)) {
                            animatePosition.toggle()
                        }
                    }
                }
            }
            .onDisappear {
                motionModel.stopUpdates()
            }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
