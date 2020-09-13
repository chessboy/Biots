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
	
	init(angle: CGFloat, radius: CGFloat, width: CGFloat, forBackground: Bool = false) {
		
		super.init()
		self.name = "retina"

		self.angle = angle
		
		let path = CGMutablePath()
		path.addArc(center: .zero, radius: radius, startAngle: angle - width, endAngle: angle + width, clockwise: false)

		self.path = path
		self.lineWidth = 5
		self.lineCap = .round
		self.strokeColor = .black
		self.isAntialiased = true

		if forBackground {
			self.lineWidth = 8
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
