//
//  Motion.swift
//  morsenator
//
//  Created by Aaron Christopher Tanhar on 16/08/23.
//

import CoreMotion
import Foundation

class HomeViewModel: ObservableObject {
    @Published var accelerationValue: String = ""
    @Published var gravityValue: String = ""
    @Published var rotationValue: String = ""

    // The instance of CMMotionManager responsible for handling sensor updates
    private let motionManager = CMMotionManager()

    // Properties to hold the sensor values
    private var userAcceleration: CMAcceleration = .init()
    private var gravity: CMAcceleration = .init()
    private var rotationRate: CMRotationRate = .init()

    init() {
        // Set the update interval to any time that you want
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // 60 Hz
        motionManager.accelerometerUpdateInterval = 1.0 / 60.0
        motionManager.gyroUpdateInterval = 1.0 / 20.0
    }

    func startUpdates() {
        accelerationValue = ""
        gravityValue = ""
        rotationValue = ""
        startFetchingSensorData()
    }

    private func startFetchingSensorData() {
        // Check if the motion manager is available and the sensors are available
        if motionManager.isDeviceMotionAvailable && motionManager.isAccelerometerAvailable && motionManager.isGyroAvailable {
            // Start updating the sensor data
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
                guard let self = self else { return } // Avoid memory leaks
                // Check if there's any error in the sensor update
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                getMotionAndGravity(motion: motion)
            }
            motionManager.startGyroUpdates(to: .main) { [weak self] gyroData, _ in
                guard let self = self else { return }
                getRotation(gyroData: gyroData)
            }
        }
    }

    private func getMotionAndGravity(motion: CMDeviceMotion?) {
        if let motion = motion {
            // Get user acceleration and gravity data
            userAcceleration = motion.userAcceleration
            gravity = motion.gravity
            // Update publishers with the new sensor data
            accelerationValue = "X: \(userAcceleration.x), \n Y: \(userAcceleration.y), \n Z: \(userAcceleration.z)"
            gravityValue = "X: \(gravity.x), \n Y: \(gravity.y), \n Z: \(gravity.z)"
        }
    }

    private func getRotation(gyroData: CMGyroData?) {
        if let gyroData = gyroData {
            // Get rotation rate data
            rotationRate = gyroData.rotationRate
            // Update publisher with the new sensor data
            rotationValue = "X: \(rotationRate.x), \n Y: \(rotationRate.y), \n Z: \(rotationRate.z)"
        }
    }

    // Function responsible for stopping the sensor updates
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
    }
}
