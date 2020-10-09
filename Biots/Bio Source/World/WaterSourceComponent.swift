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
	
	override var requiredComponents: [GKComponent.Type]? {
		[
			SpriteKitComponent.self,
			PhysicsComponent.self
		]
	}
}

extension WaterSourceComponent {
	
	static func create(radius: CGFloat, position: CGPoint) -> OKEntity {
		
		let node = SKShapeNode.polygonOfRadius(radius, sides: 12)
		node.name = "water"
		node.zPosition = Constants.ZeeOrder.water
		node.lineWidth = 4
		node.fillColor = Constants.Colors.water
		node.strokeColor = Constants.Colors.grid
		node.blendMode = Constants.Env.graphics.blendMode
		node.isAntialiased = Constants.Env.graphics.antialiased
		node.position = position

		if Constants.Env.graphics.shadows {
			let shadowWidth: CGFloat = 10
			let shadowNode = SKShapeNode.polygonOfRadius(radius + shadowWidth/2, sides: 12)
			shadowNode.zPosition = Constants.ZeeOrder.water - 0.1
			shadowNode.glowWidth = shadowWidth
			shadowNode.strokeColor = SKColor.black.withAlpha(0.167)
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
			ZapperComponent(),
			WaterSourceComponent()
		])
	}
}

