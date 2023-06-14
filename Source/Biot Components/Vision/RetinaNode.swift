//
//  RetinaNode.swift
//  Biots
//
//  Created by Robert Silverman on 9/8/18.
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
		self.strokeColor = .black
		self.blendMode = Constants.Env.graphics.blendMode
		self.isAntialiased = false

		if forBackground {
			self.lineWidth = thickness * 1.6
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
