//
//  RetinaNode.swift
//  SwiftBots
//
//  Created by Robert Silverman on 9/8/18.
//  Copyright © 2018 fep. All rights reserved.
//

import Foundation
import SpriteKit

class RetinaNode: SKShapeNode {
	
	var angle: CGFloat = 0
	
	init(angle: CGFloat, radius: CGFloat, startRadius: CGFloat, width: CGFloat, forBackground: Bool = false) {
		
		super.init()
		self.name = "RetinaNode"

		self.angle = angle
		self.position = position
		
		let path = CGMutablePath()
		path.addArc(center: .zero, radius: radius * startRadius, startAngle: angle - width, endAngle: angle + width, clockwise: false)

		self.path = path
		self.lineWidth = 6
		self.lineCap = .round
		self.strokeColor = .black
		self.isAntialiased = Constants.Display.antialiased

		if forBackground {
			self.lineJoin = .round
			self.strokeColor = .black
			self.lineWidth = 8
			self.fillColor = .black
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
