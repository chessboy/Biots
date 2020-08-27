//
//  NoiseComponent.swift
//  Cells
//
//  Created by Robert Silverman on 5/16/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

final class NoiseComponent: OKComponent {
    
	var noiseFieldNode: SKFieldNode?
	var frame = Int.random(100)

    override func didAddToEntity(withNode node: SKNode) {
		let fieldNode = SKFieldNode.noiseField(withSmoothness: 1, animationSpeed: 3)
		fieldNode.strength = 3
		node.addChild(fieldNode)
		noiseFieldNode = fieldNode
    }
    
    override func update(deltaTime seconds: TimeInterval) {
		frame += 1
		guard frame.isMultiple(of: 100), let noiseFieldNode = noiseFieldNode else { return }
		noiseFieldNode.zRotation += π/30
    }
}

