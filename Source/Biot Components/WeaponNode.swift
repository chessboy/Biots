//
//  WeaponNode.swift
//  SwiftBots
//
//  Created by Robert Silverman on 10/11/18.
//  Copyright © 2018 fep. All rights reserved.
//

import Foundation
import SpriteKit

class WeaponNode: SKNode {
	
	var spikeNode: SKShapeNode!
	
	override init() {
		super.init()
		
		spikeNode = createNode()
		addChild(spikeNode)
		
		zPosition = Constants.ZeeOrder.biot - 2
		alpha = 0
	}
	
	func update(weaponIntensity: CGFloat) {
		repathNode(spikeNode, weaponIntensity: weaponIntensity)
	}
	
	func createNode(forShadow: Bool = false) -> SKShapeNode {
		let node = SKShapeNode()
		node.lineCap = .round
		node.lineJoin = .round
		node.lineWidth = forShadow ? 1.5 : 0
		node.strokeColor = forShadow ? SKColor(white: 0.2, alpha: 0.5) : .clear
		node.fillColor = forShadow ? .black : SKColor(srgbRed: 110/255, green: 16/255, blue: 16/255, alpha: 0.8)
		node.isAntialiased = !forShadow
		node.zPosition = Constants.ZeeOrder.biot - 2
		return node
	}
	
	func repathNode(_ node: SKShapeNode, weaponIntensity: CGFloat) {
		
		guard weaponIntensity > 0 else {
			node.path = nil
			return
		}

		let countersink: CGFloat = 1.5
		let radius = Constants.Biot.radius
		let path = CGMutablePath()
		let point1 = CGPoint(angle: π/20) * (radius - countersink)
		let point2 = CGPoint(angle: 0) * ((radius - countersink) + (weaponIntensity * (Constants.Biot.spikeLength + countersink)))
		let point3 = CGPoint(angle: -π/20) * (radius - countersink)
		path.move(to: point1)
		path.addLine(to: point2)
		path.addLine(to: point3)
		path.closeSubpath()
		node.path = path
	}
	
	required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
