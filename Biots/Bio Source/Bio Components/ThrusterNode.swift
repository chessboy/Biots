//
//  ThrusterNode.swift
//  Biots
//
//  Created by Robert Silverman on 9/13/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit

class ThrusterNode: SKNode {
    
    var leftThrustPostitiveNode: SKShapeNode
    var leftThrustNegativeNode: SKShapeNode
    var rightThrustPositiveNode: SKShapeNode
    var rightThrustNegativeNode: SKShapeNode
    
    init(radius: CGFloat) {
        
		let thrusterRadius = radius * 0.6
		leftThrustPostitiveNode = RetinaNode(angle: Constants.Thrust.thrusterSpots[0], radius: thrusterRadius, width: Constants.Thrust.thrusterWidth)
        leftThrustNegativeNode = RetinaNode(angle: Constants.Thrust.thrusterSpots[1], radius: thrusterRadius, width: Constants.Thrust.thrusterWidth)
        rightThrustPositiveNode = RetinaNode(angle: Constants.Thrust.thrusterSpots[2], radius: thrusterRadius, width: Constants.Thrust.thrusterWidth)
        rightThrustNegativeNode = RetinaNode(angle: Constants.Thrust.thrusterSpots[3], radius: thrusterRadius, width: Constants.Thrust.thrusterWidth)

        super.init()

        for angleOffset: CGFloat in Constants.Thrust.thrusterSpots.reversed() {
            let node = RetinaNode(angle: angleOffset, radius: thrusterRadius, width: Constants.Thrust.thrusterWidth, forBackground: true)
            addChild(node)
        }
        
        addChild(leftThrustPostitiveNode)
        addChild(leftThrustNegativeNode)
        addChild(rightThrustPositiveNode)
        addChild(rightThrustNegativeNode)
    }
    
    func update(leftThrustIntensity: CGFloat, rightThrustIntensity: CGFloat) {
                
        for thrusterNode in [leftThrustPostitiveNode, leftThrustNegativeNode, rightThrustPositiveNode, rightThrustNegativeNode] {
            thrusterNode.strokeColor = .black
        }
        
        if leftThrustIntensity >= 0 {
            let intensity = (abs(leftThrustIntensity * 1.25)).clamped(0, 1)
            leftThrustPostitiveNode.strokeColor = SKColor(white: intensity, alpha: 1)
            leftThrustPostitiveNode.zPosition = intensity
        } else {
            let intensity = (abs(leftThrustIntensity * 1.5)).clamped(0, 1)
            leftThrustNegativeNode.strokeColor = SKColor(red: intensity, green: intensity, blue: 0, alpha: 1)
            leftThrustNegativeNode.zPosition = intensity
        }
        
        if rightThrustIntensity >= 0 {
            let intensity = (abs(rightThrustIntensity * 1.25)).clamped(0, 1)
            rightThrustPositiveNode.strokeColor = SKColor(white: intensity, alpha: 1)
            rightThrustPositiveNode.zPosition = intensity
        } else {
            let intensity = (abs(rightThrustIntensity * 1.5)).clamped(0, 1)
            rightThrustNegativeNode.strokeColor = SKColor(red: intensity, green: intensity, blue: 0, alpha: 1)
            rightThrustNegativeNode.zPosition = intensity
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
