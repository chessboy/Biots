//
//  AlgaeComponent.swift
//  Biots
//
//  Created by Robert Silverman on 4/12/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation
import GameplayKit
import OctopusKit

class AlgaeComponent: OKComponent {
	
	var energy: CGFloat = 0
	var frame = Int.random(100)
	var fromBiot = false

	init(energy: CGFloat, fromBiot: Bool) {
		self.energy = energy
		self.fromBiot = fromBiot
		super.init()
	}
	
	override var requiredComponents: [GKComponent.Type]? {[
		SpriteKitComponent.self
	]}

	public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	override func didAddToEntity(withNode node: SKNode) {
		born()
	}
	
	override func update(deltaTime seconds: TimeInterval) {
		frame += 1
		
		// energy from biots decays	 fasters
		if frame.isMultiple(of: 40), Int.oneChanceIn(fromBiot ? 10 : 20) {
			energy -= Constants.Algae.bite
			if energy < Constants.Algae.bite {
				energy = 0
			}
			bitten()
		}
	}
	
	func born() {
		if let node = entityNode {
			node.setScale(0.25)
			bitten()
		}
	}
	
	func bitten() {
		if let node = entityNode, let octopusEntity = self.octopusEntity {
			let bitesLeft = energy / Constants.Algae.bite
			
			if bitesLeft <= 0 {
				if let scene = octopusEntity.scene as? OKScene {
					let scaleAction = SKAction.scale(to: 0.2, duration: 0.25)
					let fadeAction = SKAction.fadeOut(withDuration: 0.25)
					let group = SKAction.group([scaleAction, fadeAction])
					node.run(group, completion: {
						self.coComponent(ofType: ResourceFountainComponent.self)?.removeAlgaeEntity(algaeEntity: octopusEntity)
						scene.removeEntityOnNextUpdate(octopusEntity)
					})
				}
			}
			else {
				let scale = 0.4 + (bitesLeft - 1) * 0.2
				node.run(SKAction.scale(to: scale, duration: 0.25))
			}
		}
	}
}

extension AlgaeComponent {
	
	static func create(position: CGPoint, energy: CGFloat, fromBiot: Bool) -> OKEntity {

		let blendColor: SKColor = Bool.random() ? .yellow : .brown		
		let color = fromBiot ? Constants.VisionColors.algaeFromBiot : Constants.Colors.algae.blended(withFraction: CGFloat.random(in: 0..<0.5), of: blendColor) ?? Constants.Colors.algae
		let radius = Constants.Algae.radius
		let node = SKShapeNode.polygonOfRadius(radius, sides: fromBiot ? 12 : 8, cornerRadius: radius/4, lineWidth: 0, rotationOffset: 0)

		node.position = position
		node.fillColor = color
		node.lineWidth = 0
		node.zPosition = Constants.ZeeOrder.algae
		node.blendMode = Constants.Env.graphics.blendMode
		node.isAntialiased = Constants.Env.graphics.isAntialiased
		node.isHidden = true
		let range = SKRange(lowerLimit: 0, upperLimit: Constants.Env.worldRadius * 0.9)
		let keepInBounds = SKConstraint.distance(range, to: .zero)
		node.constraints = [keepInBounds]
		
		if Constants.Env.graphics.shadows {
			let shadowNode = SKShapeNode()
			shadowNode.path = node.path
			shadowNode.glowWidth = 5
			shadowNode.zPosition = Constants.ZeeOrder.algae - 2
			shadowNode.strokeColor = SKColor.black.withAlpha(0.2)
			node.insertChild(shadowNode, at: 0)
		}

		let bufferNode = SKShapeNode(circleOfRadius: radius * 1.25)
		let physicsBody = SKPhysicsBody(polygonFrom: bufferNode.path!)

		physicsBody.categoryBitMask = Constants.CategoryBitMasks.algae
		physicsBody.collisionBitMask = Constants.CollisionBitMasks.algae
		//physicsBody.contactTestBitMask = Constants.ContactBitMasks.algae
		physicsBody.mass = 3
		physicsBody.angularDamping = 0.9
		physicsBody.linearDamping = 0.9
		//physicsBody.usesPreciseCollisionDetection = true

		return OKEntity(name: Constants.NodeName.algae, components: [
			SpriteKitComponent(node: node),
			PhysicsComponent(physicsBody: physicsBody),
			AlgaeComponent(energy: energy, fromBiot: fromBiot)
		])
	}
}
