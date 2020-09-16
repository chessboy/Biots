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
	
	init(angle: CGFloat, radius: CGFloat, thickness: CGFloat, arcLength: CGFloat, forBackground: Bool = false) {
		
		super.init()
		self.name = "retina"

		self.angle = angle
		
		let path = CGMutablePath()
		path.addArc(center: .zero, radius: radius, startAngle: angle - arcLength, endAngle: angle + arcLength, clockwise: false)

		self.path = path
		self.lineWidth = thickness
		self.lineCap = .round
		self.strokeColor = .black //SKColor(white: 0.125, alpha: 1)
		self.blendMode = Constants.Env.graphics.blendMode
		self.isAntialiased = Constants.Env.graphics.antialiased

		if forBackground {
			self.lineWidth = thickness * 1.6
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
