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
	var isSelected = false
	var isMud = false
	
	init(radius: CGFloat, isMud: Bool) {
		self.radius = radius
		self.isMud = isMud
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

extension WaterSourceComponent {
	
	static func create(radius: CGFloat, position: CGPoint, isMud: Bool = false) -> OKEntity {
		
		let node = SKSpriteNode(imageNamed: isMud ? "Mud" : "Water")
		node.size = CGSize(width: radius*2.4, height: radius*2.4)
		node.name = Constants.NodeName.water
		node.zPosition = Constants.ZeeOrder.water
		node.blendMode = Constants.Env.graphics.blendMode
		node.position = position

		//let color = isMud ? Constants.Colors.mud.withAlpha(0.8) : Constants.Colors.water.withAlpha(0.8)

		let physicsBody = SKPhysicsBody(circleOfRadius: radius)
		physicsBody.allowsRotation = false
		physicsBody.mass = 20
		physicsBody.categoryBitMask = Constants.CategoryBitMasks.water
		physicsBody.collisionBitMask = Constants.CollisionBitMasks.water
		
		return OKEntity(components: [
			SpriteKitComponent(node: node),
			PhysicsComponent(physicsBody: physicsBody),
			WaterSourceComponent(radius: radius, isMud: isMud)
		])
	}
}

