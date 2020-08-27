//
//  RulerComponent.swift
//  BioGenesis
//
//  Created by Robert Silverman on 4/13/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

final class RulerComponent: OKComponent {
}

extension RulerComponent {
	
	static func createRuler(position: CGPoint) -> OKEntity {
		
		let rootNode = SKNode()
		
		for i in 0..<20 {
			let node = SKShapeNode(rectOf: CGSize(width: 50, height: 50))
			let color: SKColor = i.isMultiple(of: 2) ? .lightGray : .white
			node.position = position + CGPoint(angle: 0) * CGFloat(50 * i)
			node.fillColor = color
			node.lineWidth = 0
			rootNode.addChild(node)
		}
		
		rootNode.position -= CGPoint(x: 500, y: 0)
		
		return OKEntity(components: [
			RulerComponent(),
			SpriteKitComponent(node: rootNode),
		])
	}
}

