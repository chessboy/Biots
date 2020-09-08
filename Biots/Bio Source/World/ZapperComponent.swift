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
		
		let node = SKShapeNode.polygonOfRadius(radius, sides: 8)
		node.name = "wall"
		node.zPosition = Constants.ZeeOrder.wall
		node.lineWidth = 0
		node.fillColor = Constants.Colors.wall
		node.strokeColor = .clear
		//node.blendMode = .replace
		node.isAntialiased = Constants.Display.antialiased
		node.position = position

		let shadowWidth: CGFloat = 10
		let shadowNode = SKShapeNode.polygonOfRadius(radius + shadowWidth/2, sides: 8)
		shadowNode.zPosition = Constants.ZeeOrder.wall - 0.1
		shadowNode.glowWidth = shadowWidth
		shadowNode.strokeColor = SKColor.black.withAlpha(0.167)
		node.addChild(shadowNode)

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

