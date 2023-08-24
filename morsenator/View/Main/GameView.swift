//
//  GameView.swift
//  morsenator
//
//  Created by Aaron Christopher Tanhar on 24/08/23.
//

import SpriteKit

class GameScene: SKScene {
    var ball: SKShapeNode?

    override func didMove(to view: SKView) {
        oneLittleCircle()
        view.allowsTransparency = true
        backgroundColor = .clear
        view.isOpaque = true
        view.backgroundColor = .clear
    }

    public func updateMotion(pitch: Double, roll: Double) {
        // Perform the translation
        let prevPosition = ball?.position
        let newPosition = CGPoint(
            x: prevPosition!.x + (roll * 3),
            y: prevPosition!.y + (-pitch * 3)
        )
        if newPosition.x < frame.maxX && newPosition.x > frame.minX && newPosition.y > frame.minY && newPosition.y < frame.maxY {
            ball!.position = newPosition
        }
    }

    func oneLittleCircle() {
        let Circle = SKShapeNode(circleOfRadius: 80) // Size of Circle
        Circle.position = CGPoint(x: frame.midX, y: frame.midY) // Middle of Screen
        Circle.strokeColor = SKColor.black
        Circle.glowWidth = 1.0
        Circle.fillColor = SKColor.orange
        ball = Circle
        addChild(Circle)
    }
}
