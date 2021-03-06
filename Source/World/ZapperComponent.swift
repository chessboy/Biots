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
	
	var radius: CGFloat
	var isBrick: Bool
	
	init(radius: CGFloat, isBrick: Bool) {
		self.radius = radius
		self.isBrick = isBrick
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override var requiredComponents: [GKComponent.Type]? {[
			SpriteKitComponent.self,
			PhysicsComponent.self
		]
	}
}

extension ZapperComponent {
	
	static func create(radius: CGFloat, position: CGPoint, isBrick: Bool) -> OKEntity {
		
		let node = SKSpriteNode(imageNamed: isBrick ? "Brick" : "Zapper")
		let scale: CGFloat = 2.075
		node.size = CGSize(width: radius*scale, height: radius*scale)
		node.name = Constants.NodeName.zapper
		node.zPosition = Constants.ZeeOrder.wall
		node.blendMode = Constants.Env.graphics.blendMode
		node.position = position

		let physicsNode = SKShapeNode.polygonOfRadius(radius, sides: 8, cornerRadius: radius/4, lineWidth: 4, rotationOffset: π/8)
		let physicsBody = SKPhysicsBody(polygonFrom: physicsNode.path!)
		physicsBody.allowsRotation = false
		physicsBody.mass = 20
		physicsBody.categoryBitMask = Constants.CategoryBitMasks.wall
		physicsBody.collisionBitMask = Constants.CollisionBitMasks.wall
		
		return OKEntity(components: [
			SpriteKitComponent(node: node),
			PhysicsComponent(physicsBody: physicsBody),
			ZapperComponent(radius: radius, isBrick: isBrick)
		])
	}
}

