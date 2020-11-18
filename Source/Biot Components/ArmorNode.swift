//
//  ArmorNode.swift
//  Biots
//
//  Created by Rob Silverman on 11/17/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation
import SpriteKit

class ArmorNode: SKNode {
		
	init(species: Species) {
		super.init()
		
		let radius = Constants.Biot.radius
	
		if species == .omnivore {
			addChild(createNode(radius: radius, path: createSidePath(radius: radius, rotation: 0)))
			addChild(createNode(radius: radius, path: createSidePath(radius: radius, rotation: π + π/12 + π/24)))
		} else {
			addChild(createNode(radius: radius, path: createFullPath(radius: radius)))
		}

		zPosition = Constants.ZeeOrder.biot - 2
		alpha = 0
	}
	
	func createSidePath(radius: CGFloat, rotation: CGFloat) -> CGPath {
		let path = CGMutablePath()
		path.addArc(center: .zero, radius: radius * 1.1, startAngle: rotation + π/12, endAngle: rotation + (π - π/6 - π/24), clockwise: false)
		return path
	}
	
	func createFullPath(radius: CGFloat) -> CGPath {
		let path = CGMutablePath()
		path.addArc(center: .zero, radius: radius * 1.1, startAngle: π - π/6 - π/24, endAngle: π + π/6 + π/24, clockwise: true)
		return path
	}

	func createNode(radius: CGFloat, path: CGPath) -> SKShapeNode {
		let node = SKShapeNode()
		node.path = path
		node.fillColor = .clear
		node.lineWidth = radius * 0.1
		node.lineCap = .round
		node.strokeColor = .green
		node.zPosition = Constants.ZeeOrder.biot - 2
		node.isAntialiased = Constants.Env.graphics.isAntialiased

		return node
	}
		
	required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
