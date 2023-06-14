//
//  ProgressNode.swift
//  SwiftBots
//
//  Created by Robert Silverman on 10/3/18.
//

import Foundation
import SpriteKit

class ProgressNode: SKShapeNode {

	var emptyRing: SKShapeNode
	var progressRing: SKShapeNode
	var radius: CGFloat
	
	init(radius: CGFloat, lineWidth: CGFloat) {
		
		self.radius = radius
		
		emptyRing = SKShapeNode(circleOfRadius: radius + lineWidth * 0.75)
		progressRing = SKShapeNode(circleOfRadius: radius)

		super.init()
		
		emptyRing.lineWidth = 0
		emptyRing.fillColor = SKColor(white: 0.1, alpha: 1)
		emptyRing.blendMode = Constants.Env.graphics.blendMode
		emptyRing.isAntialiased = Constants.Env.graphics.isAntialiased
		self.addChild(emptyRing)

		progressRing.lineWidth = lineWidth
		progressRing.lineCap = .round
		progressRing.fillColor = .clear
		progressRing.strokeColor = .black
		progressRing.blendMode = Constants.Env.graphics.blendMode
		progressRing.isAntialiased = false
		self.addChild(progressRing)
		
		setProgress(0)
	}
	
	func setProgress(_ value: CGFloat) {
		
		let progress = (value).clamped(0.001, 0.999)
		let endAngle = 2*π * (1 - progress)
		
		//print("setProgress: progress: \(progress.formattedTo2Places), endAngle: \(endAngle.formattedTo2Places)")

		let path = CGMutablePath()
		path.addArc(center: .zero, radius: radius, startAngle: 0, endAngle: endAngle, clockwise: true)
		progressRing.path = path
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
