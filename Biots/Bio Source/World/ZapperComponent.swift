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

extension ZapperComponent {
	
	static func create(radius: CGFloat, position: CGPoint) -> OKEntity {
		
		let color = Constants.Colors.wall

		let node = SKShapeNode.polygonOfRadius(radius, sides: 8, cornerRadius: radius/4, lineWidth: 4, rotationOffset: π/8)
		node.name = "zapper"
		node.zPosition = Constants.ZeeOrder.wall
		node.lineWidth = 4
		node.fillColor = color
		node.strokeColor = Constants.Colors.grid
		node.blendMode = Constants.Env.graphics.blendMode
		node.isAntialiased = Constants.Env.graphics.antialiased
		node.position = position

		if Constants.Env.graphics.shadows {
			let shadowWidth: CGFloat = 10
			let shadowRadius = radius + shadowWidth/2
			let shadowNode =  SKShapeNode.polygonOfRadius(shadowRadius, sides: 8, cornerRadius: shadowRadius/4, lineWidth: 4, rotationOffset: π/8)
			shadowNode.zPosition = Constants.ZeeOrder.wall - 0.1
			shadowNode.glowWidth = shadowWidth
			shadowNode.lineWidth = shadowWidth
			shadowNode.strokeColor = SKColor.black.withAlpha(0.167)
			node.insertChild(shadowNode, at: 0)
		}
		
		if Constants.Env.graphics.blendMode != .replace {
			for scale: CGFloat in [0.92, 0.84, 0.76] {
			
				let rippleRadius = radius * scale
				let rippleNode = SKShapeNode.polygonOfRadius(rippleRadius, sides: 8, cornerRadius: rippleRadius/4, lineWidth: 8, rotationOffset: π/8)
				rippleNode.blendMode = Constants.Env.graphics.blendMode
				rippleNode.fillColor = SKColor.white.withAlpha(scale/33)
				node.addChild(rippleNode)
			}
		}

		let physicsBody = SKPhysicsBody(polygonFrom: node.path!)

		physicsBody.allowsRotation = false
		physicsBody.mass = 20
		physicsBody.categoryBitMask = Constants.CategoryBitMasks.wall
		physicsBody.collisionBitMask = Constants.CollisionBitMasks.wall
		
		return OKEntity(components: [
			SpriteKitComponent(node: node),
			PhysicsComponent(physicsBody: physicsBody),
			ZapperComponent(radius: radius)
		])
	}
}

