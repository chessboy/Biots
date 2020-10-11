//
//  WaterSourceComponent.swift
//  Biots
//
//  Created by Robert Silverman on 10/8/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

final class WaterSourceComponent: OKComponent {
	
	var radius: CGFloat
	
	init(radius: CGFloat) {
		self.radius = radius
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override var requiredComponents: [GKComponent.Type]? {
		[
			SpriteKitComponent.self,
			PhysicsComponent.self
		]
	}
}

extension WaterSourceComponent {
	
	static func create(radius: CGFloat, position: CGPoint) -> OKEntity {
		
		let color = Constants.Colors.water.blended(withFraction: CGFloat.random(in: 0..<0.15), of: SKColor.blue) ?? Constants.Colors.water

		let node = SKShapeNode.polygonOfRadius(radius, sides: 12, cornerRadius: radius/4, lineWidth: 0, rotationOffset: π/12)
		node.name = "water"
		node.zPosition = Constants.ZeeOrder.water
		node.lineWidth = Constants.Env.graphics.shadows ? 0 : 8
		node.fillColor = color
		node.strokeColor = color.blended(withFraction: 0.1, of: .white) ?? .white
		node.blendMode = Constants.Env.graphics.blendMode
		node.isAntialiased = Constants.Env.graphics.antialiased
		node.position = position

		if Constants.Env.graphics.shadows {
			let shadowWidth: CGFloat = 5
			let shadowRadius = radius - (shadowWidth * 1.5)
			let shadowNode =  SKShapeNode.polygonOfRadius(shadowRadius, sides: 12, cornerRadius: shadowRadius/4, lineWidth: 4, rotationOffset: π/12)
			shadowNode.zPosition = Constants.ZeeOrder.water - 0.1
			shadowNode.glowWidth = shadowWidth
			shadowNode.lineWidth = shadowWidth
			shadowNode.strokeColor = SKColor.white.withAlpha(0.167)
			node.addChild(shadowNode)
		}

		let physicsBody = SKPhysicsBody(polygonFrom: node.path!)

		physicsBody.allowsRotation = false
		physicsBody.mass = 20
		physicsBody.categoryBitMask = Constants.CategoryBitMasks.water
		physicsBody.collisionBitMask = Constants.CollisionBitMasks.water
		
		return OKEntity(components: [
			SpriteKitComponent(node: node),
			PhysicsComponent(physicsBody: physicsBody),
			WaterSourceComponent(radius: radius)
		])
	}
}
