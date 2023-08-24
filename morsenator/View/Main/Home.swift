//
//  Home.swift
//  morsenator
//
//  Created by Aaron Christopher Tanhar on 07/08/23.
//

import CoreHaptics
import SpriteKit
import SwiftUI

struct Home: View {
    @State private var animateGradient = false
    @EnvironmentObject var motionModel: MotionModel
    @EnvironmentObject var timerController: TimerController
    @State private var roll = false
    @State private var pitch = false
    @State private var rollNum = 0.0
    @State private var pitchNum = 0.0
    @State private var animatePosition = false

    let maxRad = 3.14159

    func updateMotion() {
        rollNum = motionModel.getAttitude()?.roll ?? 0
        pitchNum = motionModel.getAttitude()?.pitch ?? 0
        roll = rollNum > 0
        pitch = pitchNum > 0
    }

    let scene: GameScene = {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let scene = GameScene()
        scene.size = CGSize(width: screenWidth, height: screenHeight)
        scene.scaleMode = .fill

        return scene
    }()

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Image("Logo").resizable().frame(width: 200, height: 200).padding(.bottom)
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
                    }.buttonStyle(MainButton(width: UIDevice.isIPad ? 400 : 200, height: UIDevice.isIPad ? 75 : 35)).font(UIDevice.isIPad ? .largeTitle : .title2).padding(.bottom)
                    NavigationLink {
                        MainView()
                    } label: {
                        Label("Vision", systemImage: "eye.circle")
                    }.buttonStyle(MainButton(width: UIDevice.isIPad ? 400 : 200, height: UIDevice.isIPad ? 75 : 35)).font(UIDevice.isIPad ? .largeTitle : .title2).padding(.bottom)
                    NavigationLink {
                        MorseMainView()
                    } label: {
                        Label("AVFoundation", systemImage: "speaker.wave.2.circle")
                    }.buttonStyle(MainButton(width: UIDevice.isIPad ? 400 : 200, height: UIDevice.isIPad ? 75 : 35)).font(UIDevice.isIPad ? .largeTitle : .title2).padding(.bottom)
                    NavigationLink {
                        PDFKitView(url: URL(string: "https://rsgb.org/main/files/2012/10/Morse_Code_Sheet_01.pdf")!).scaledToFill().navigationTitle("Guide")
                    } label: {
                        Label("Guide", systemImage: "book.circle")
                    }.buttonStyle(MainButton(width: UIDevice.isIPad ? 400 : 200, height: UIDevice.isIPad ? 75 : 35)).font(UIDevice.isIPad ? .largeTitle : .title2).padding(.bottom)
                    NavigationLink {
                        WebView(url: URL(string: "https://www.aaronct.dev/product/morsenator")!).navigationTitle("About")
                    } label: {
                        Label("About", systemImage: "questionmark.circle")
                    }.buttonStyle(MainButton(width: UIDevice.isIPad ? 400 : 200, height: UIDevice.isIPad ? 75 : 35)).font(UIDevice.isIPad ? .largeTitle : .title2).padding(.bottom)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // 1
            .background(
                ZStack {
                    LinearGradient(colors: [.black, .green], startPoint: animatePosition ? .topLeading : .bottomLeading, endPoint: animatePosition ? .bottomTrailing : .topTrailing)
                        .ignoresSafeArea()
                        .hueRotation(.degrees(animateGradient ? 45 : 0))
                        .onAppear {
                            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: true)) {
                                animateGradient.toggle()
                            }
                        }
                    SpriteView(scene: scene, options: [.allowsTransparency])
                        .ignoresSafeArea()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                }
            )
        }.navigationViewStyle(StackNavigationViewStyle())
            .onAppear {
                motionModel.startUpdates()
                timerController.setTimer(key: "statTimer", withInterval: 0.01) {
                    let oldPitch = pitch
                    updateMotion()
                    if pitch != oldPitch {
                        withAnimation(.linear(duration: 2.0)) {
                            animatePosition.toggle()
                        }
                    }
                    scene.updateMotion(pitch: pitchNum, roll: rollNum)
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
