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
    
	var fixed = false
	var radius: CGFloat
	var driftForce: CGVector = .zero
	var thrusterAngle: CGFloat = 0

    override var requiredComponents: [GKComponent.Type]? {
		[
			SpriteKitComponent.self,
			PhysicsComponent.self
		]
    }
    
	init(fixed: Bool = false, radius: CGFloat) {
		self.fixed = fixed
		self.radius = radius
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func didAddToEntity(withNode node: SKNode) {
        setRandomCourse()
    }
    
    override func update(deltaTime seconds: TimeInterval) {
		
		guard !fixed, let node = entityNode, let physicsBody = node.physicsBody, let frame = OctopusKit.shared.currentScene?.currentFrameNumber else {
			return
		}
		
		let thrusterPoint = node.position + CGPoint(angle: node.zRotation + thrusterAngle) * radius
		physicsBody.applyForce(driftForce, at: thrusterPoint)
		
		if frame % 500 == 0 {
			setRandomCourse()
		}
    }
    
	func setRandomCourse() {
		
		if !fixed {
			thrusterAngle = CGFloat.randomAngle
			let force: CGFloat = 100
			driftForce = CGVector(angle: CGFloat.randomAngle) * force * CGFloat.randomSign
			//print("driftForce: (\(driftForce.dx.formattedTo2Places), \(driftForce.dy.formattedTo2Places)) for radius: bodyComponent.sizeRadius")
		}
	}
}

extension ZapperComponent {
	
	static func createZapper(fixed: Bool = false, radius: CGFloat, position: CGPoint) -> OKEntity {
		
		let node = SKShapeNode(circleOfRadius: radius)
		node.name = "wall"
		node.zPosition = Constants.ZeeOrder.wall
		node.lineWidth = 0
		node.fillColor = Constants.Colors.wall
		node.strokeColor = .clear
		//node.blendMode = .replace
		node.isAntialiased = false
		node.position = position

		let physicsBody = SKPhysicsBody(circleOfRadius: radius)

		physicsBody.allowsRotation = false
		physicsBody.mass = 20
		physicsBody.categoryBitMask = Constants.CategoryBitMasks.wall
		physicsBody.collisionBitMask = Constants.CollisionBitMasks.wall

		if fixed {
			physicsBody.isDynamic = false
		}

		let zapperComponent = ZapperComponent(radius: radius)
		
		return OKEntity(components: [
			SpriteKitComponent(node: node),
			PhysicsComponent(physicsBody: physicsBody),
			zapperComponent
		])
	}
}

