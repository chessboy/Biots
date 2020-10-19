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
		
		let color = Constants.Colors.water.withAlpha(0.8)

		let node = SKShapeNode.polygonOfRadius(radius, sides: 12, cornerRadius: radius/4, lineWidth: 8, rotationOffset: π/12)
		node.name = Constants.NodeName.water
		node.zPosition = Constants.ZeeOrder.water
		node.lineWidth = Constants.Env.graphics.shadows ? 0 : 4
		node.fillColor = color
		node.strokeColor = color.blended(withFraction: 0.1, of: .white) ?? .white
		node.blendMode = Constants.Env.graphics.blendMode
		node.isAntialiased = Constants.Env.graphics.isAntialiased
		node.position = position

		if Constants.Env.graphics.blendMode != .replace {
			for scale: CGFloat in [0.92, 0.84, 0.76] {
				let rippleRadius = radius * scale
				let rippleNode = SKShapeNode.polygonOfRadius(rippleRadius, sides: 12, cornerRadius: rippleRadius/4, lineWidth: 8, rotationOffset: π/12)
				rippleNode.blendMode = Constants.Env.graphics.blendMode
				rippleNode.fillColor = SKColor.black.withAlpha(scale/10)
				node.addChild(rippleNode)
			}
		}

		if Constants.Env.graphics.shadows {
			let shadowWidth: CGFloat = sqrt(radius)
			let shadowRadius = radius
			let shadowNode =  SKShapeNode.polygonOfRadius(shadowRadius, sides: 12, cornerRadius: shadowRadius/4, lineWidth: 8, rotationOffset: π/12)
			shadowNode.zPosition = Constants.ZeeOrder.water
			shadowNode.glowWidth = shadowWidth
			shadowNode.lineWidth = shadowWidth
			shadowNode.strokeColor = color.withAlpha(0.33)
			node.insertChild(shadowNode, at: 0)
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

