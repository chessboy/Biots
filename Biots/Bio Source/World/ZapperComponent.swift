//
//  ZapperComponent.swift
//  Biots
//
//  Created by Robert Silverman on 9/2/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

final class ZapperComponent: OKComponent {
	
	override var requiredComponents: [GKComponent.Type]? {
		[
			SpriteKitComponent.self,
			PhysicsComponent.self
		]
	}
}

extension ZapperComponent {
	
	static func create(radius: CGFloat, position: CGPoint) -> OKEntity {
		
		let blendColor: SKColor = Bool.random() ? .yellow : .orange
		let color = Constants.Colors.wall.blended(withFraction: CGFloat.random(in: 0..<0.15), of: blendColor) ?? Constants.Colors.wall

		let node = SKShapeNode.polygonOfRadius(radius, sides: 8)
		node.name = "wall"
		node.zPosition = Constants.ZeeOrder.wall
		node.lineWidth = 4
		node.fillColor = color
		node.strokeColor = Constants.Colors.grid
		node.blendMode = Constants.Env.graphics.blendMode
		node.isAntialiased = Constants.Env.graphics.antialiased
		node.position = position

		if Constants.Env.graphics.shadows {
			let shadowWidth: CGFloat = 10
			let shadowNode = SKShapeNode.polygonOfRadius(radius + shadowWidth/2, sides: 8)
			shadowNode.zPosition = Constants.ZeeOrder.wall - 0.1
			shadowNode.glowWidth = shadowWidth
			shadowNode.strokeColor = SKColor.black.withAlpha(0.167)
			node.addChild(shadowNode)
		}

		let physicsBody = SKPhysicsBody(polygonFrom: node.path!)

		physicsBody.allowsRotation = false
		physicsBody.mass = 20
		physicsBody.categoryBitMask = Constants.CategoryBitMasks.wall
		physicsBody.collisionBitMask = Constants.CollisionBitMasks.wall
		
		return OKEntity(components: [
			SpriteKitComponent(node: node),
			PhysicsComponent(physicsBody: physicsBody),
			ZapperComponent()
		])
	}
}

