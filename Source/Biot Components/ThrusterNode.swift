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
		
		let thrusterRadius = radius * 0.55
		let arcLength = Constants.Thrust.thrusterArc
		let thickness = radius/8
		
		leftThrustPostitiveNode = RetinaNode(angle: Constants.Thrust.thrusterSpots[0], radius: thrusterRadius, thickness: thickness, arcLength: arcLength)
		leftThrustNegativeNode = RetinaNode(angle: Constants.Thrust.thrusterSpots[1], radius: thrusterRadius, thickness: thickness, arcLength: arcLength)
		rightThrustPositiveNode = RetinaNode(angle: Constants.Thrust.thrusterSpots[2], radius: thrusterRadius, thickness: thickness, arcLength: arcLength)
		rightThrustNegativeNode = RetinaNode(angle: Constants.Thrust.thrusterSpots[3], radius: thrusterRadius, thickness: thickness, arcLength: arcLength)

		super.init()

		for angleOffset: CGFloat in Constants.Thrust.thrusterSpots.reversed() {
			let node = RetinaNode(angle: angleOffset, radius: thrusterRadius, thickness: thickness, arcLength: arcLength, forBackground: true)
			node.zPosition = Constants.ZeeOrder.biot
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
			leftThrustPostitiveNode.zPosition = Constants.ZeeOrder.biot + intensity
		} else {
			let intensity = (abs(leftThrustIntensity * 1.5)).clamped(0, 1)
			leftThrustNegativeNode.strokeColor = SKColor(red: intensity, green: intensity, blue: 0, alpha: 1)
			leftThrustNegativeNode.zPosition = Constants.ZeeOrder.biot + intensity
		}
		
		if rightThrustIntensity >= 0 {
			let intensity = (abs(rightThrustIntensity * 1.25)).clamped(0, 1)
			rightThrustPositiveNode.strokeColor = SKColor(white: intensity, alpha: 1)
			rightThrustPositiveNode.zPosition = Constants.ZeeOrder.biot + intensity
		} else {
			let intensity = (abs(rightThrustIntensity * 1.5)).clamped(0, 1)
			rightThrustNegativeNode.strokeColor = SKColor(red: intensity, green: intensity, blue: 0, alpha: 1)
			rightThrustNegativeNode.zPosition = Constants.ZeeOrder.biot + intensity
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
