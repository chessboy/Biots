//
//  StatsNode.swift
//  Biots
//
//  Created by Robert Silverman on 4/15/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation
import SpriteKit

class StatsNode: SKNode {
	
	var backgroundNode: SKShapeNode!
	var labelNodes: [SKLabelNode] = [SKLabelNode]()
	var bodyRadius: CGFloat = 0
	
	init(bodyRadius: CGFloat, fontSize: CGFloat) {
		
		super.init()
		self.name = "StatsNode"

		self.bodyRadius = bodyRadius

		backgroundNode = SKShapeNode(rectOf: .zero, cornerRadius: 10)
		backgroundNode.fillColor = SKColor.black.withAlphaComponent(0.75)
		backgroundNode.lineWidth = 0
		backgroundNode.isHidden = true
		backgroundNode.zPosition = Constants.ZeeOrder.biot + 1
		self.addChild(backgroundNode)

		let padding: CGFloat = fontSize + 40
		for i in 0..<Constants.Biot.Stats.maxLinesOfText {
			
			let node = SKLabelNode(fontNamed: Constants.Font.regular)
			node.position = CGPoint(x: 0, y: (-padding * CGFloat(i)) - bodyRadius - padding - 100)
			node.fontSize = fontSize
			node.fontColor = SKColor.white
			node.horizontalAlignmentMode = .left
			node.zPosition = Constants.ZeeOrder.biot + 1.1
			
			labelNodes.append(node)
			self.addChild(node)
		}
	}
	
	func clearAllText() {
		labelNodes.forEach({ $0.text = "" })
	}
	
	func setLineOfText(_ text: String, for line: Constants.Biot.StatsLine) {
		
		let index = line.rawValue
		
		guard index < Constants.Biot.Stats.maxLinesOfText else { return }
		
		let labelNode = labelNodes[index]
		labelNode.text = text
		labelNode.position = CGPoint(x: -labelNode.frame.width/2, y: labelNode.position.y)
	}
	
	func setLineOfText(_ text: NSAttributedString, for line: Constants.Biot.StatsLine) {
		
		let index = line.rawValue
		
		guard index < Constants.Biot.Stats.maxLinesOfText else { return }
		
		let labelNode = labelNodes[index]
		labelNode.attributedText = text
		labelNode.position = CGPoint(x: -labelNode.frame.width/2, y: labelNode.position.y)
	}

	func updateBackgroundNode() {
		
		var maxX: CGFloat = 0
		var linesVisible = 0
		
		labelNodes.forEach({
			if ($0.text != nil && $0.text != "") || ($0.attributedText != nil && $0.attributedText?.string != "") {
				linesVisible += 1
				maxX = max(maxX, $0.frame.maxX)
			}
		})
		
		guard linesVisible > 0 else {
			backgroundNode.isHidden = true
			return
		}

		backgroundNode.isHidden = false
		let minY = labelNodes[linesVisible - 1].frame.minY
		let maxY = labelNodes[0].frame.maxY
		let padding: CGFloat = 30
		
		let rect = CGRect(x: -maxX - padding, y: minY - padding, width: maxX * 2 + (2 * padding), height: maxY - minY + (2 * padding))
		//print("maxX: \(maxX), maxY: \(maxY), rect: \(rect)")
		backgroundNode.path = CGPath(roundedRect: rect, cornerWidth: 20, cornerHeight: 20, transform: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
