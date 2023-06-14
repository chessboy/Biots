//
//  WeaponNode.swift
//  SwiftBots
//
//  Created by Robert Silverman on 10/11/18.
//

import Foundation
import SpriteKit

class WeaponNode: SKNode {
	
	static let weaponColor = SKColor(srgbRed: 110/255, green: 16/255, blue: 16/255, alpha: 1)
	static let minimumWeaponIntensity: CGFloat = 0.075
	
	var spikeNode: SKShapeNode!
	var defaultPath: CGPath!
	
	override init() {
		super.init()
		
		defaultPath = createPath(weaponIntensity: WeaponNode.minimumWeaponIntensity)

		spikeNode = createNode()
		addChild(spikeNode)
		zPosition = Constants.ZeeOrder.biot - 2
		alpha = 0
	}
	
	func update(weaponIntensity: CGFloat, isFeeding: Bool) {
		guard weaponIntensity > WeaponNode.minimumWeaponIntensity else {
			spikeNode.path = defaultPath
			spikeNode.fillColor = .orange
			return
		}
		repathNode(spikeNode, weaponIntensity: weaponIntensity.clamped(0, 1))
		spikeNode.fillColor = isFeeding ? .red : SKColor.orange.blended(withFraction: weaponIntensity, of: WeaponNode.weaponColor)?.withAlpha(0.8) ?? .red
	}
	
	func createNode() -> SKShapeNode {
		let node = SKShapeNode()
		node.lineCap = .round
		node.lineJoin = .round
		node.lineWidth =  0
		node.strokeColor = .clear
		node.fillColor = .orange
		node.isAntialiased = Constants.Env.graphics.isAntialiased
		node.zPosition = Constants.ZeeOrder.biot - 2
		return node
	}
	
	func repathNode(_ node: SKShapeNode, weaponIntensity: CGFloat) {
		node.path = createPath(weaponIntensity: weaponIntensity)
	}
	
	func createPath(weaponIntensity: CGFloat) -> CGPath {
		let countersink: CGFloat = 1.5
		let radius = Constants.Biot.radius
		let baseWidth = π/16
		let path = CGMutablePath()
		let point1 = CGPoint(angle: baseWidth) * (radius - countersink)
		let point2 = CGPoint(angle: 0) * ((radius - countersink) + (weaponIntensity * (Constants.Biot.spikeLength + countersink)))
		let point3 = CGPoint(angle: -baseWidth) * (radius - countersink)
		path.move(to: point1)
		path.addLine(to: point2)
		path.addLine(to: point3)
		path.closeSubpath()
		
		return path
	}
	
	required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
