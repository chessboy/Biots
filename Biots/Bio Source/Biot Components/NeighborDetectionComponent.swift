//
//  BodyDetectionComponent.swift
//  BioGenesis
//
//  Created by Robert Silverman on 4/14/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

struct Detection {
	var categoryBitMask: UInt32
	var position: CGPoint
}

final class BodyDetectionComponent: OKComponent, OKUpdatableComponent {
	
    override var requiredComponents: [GKComponent.Type]? {[
		SpriteKitComponent.self,
		PhysicsComponent.self
	]}
	
	func detections(within radius: CGFloat, detectionBitMask: UInt32) -> [Detection] {
		var neighbors: [Detection] = []

		if let position = coComponent(SpriteKitComponent.self)?.node.position {
			let rect = CGRect(origin: CGPoint(x: position.x - radius, y: position.y - radius), size: CGSize(width: radius*2, height: radius*2))

			if let scene = OctopusKit.shared.currentScene,
				let physicsBody = coComponent(PhysicsComponent.self)?.physicsBody {
				
				scene.physicsWorld.enumerateBodies(in: rect) { (otherPhysicsBody, stop) in
					let otherCategoryBitMask = otherPhysicsBody.categoryBitMask
					if physicsBody != otherPhysicsBody, (otherCategoryBitMask & detectionBitMask > 0), let otherPosition = otherPhysicsBody.node?.position,
						position.distance(to: otherPosition) <= radius {
							neighbors.append(Detection(categoryBitMask: otherCategoryBitMask, position: otherPosition))
						}
				}
			}
		}
		
		return neighbors
	}
}
