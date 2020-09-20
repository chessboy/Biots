//
//  SpriteKitExtensions.swift
//  BioGenesis
//
//  Created by Robert Silverman on 4/13/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreGraphics

extension SKShapeNode {
	
	static func polygonOfRadius(_ radius: CGFloat, sides: Int) -> SKShapeNode {
		
		var points: [CGPoint] = []
		
		let startAngle = 2.0 * π / sides.cgFloat / 2.0
		
		for i in 0...sides {
			let rotationFactor = ((2.0 * π) / sides.cgFloat) * (i.cgFloat) + startAngle
			let x = cos(rotationFactor) * radius
			let y = sin(rotationFactor) * radius
			let point = CGPoint(x: x, y: y)
			points.append(point)
		}
		
		return SKShapeNode(points: &points, count: points.count)
	}
	
	static func arcOfRadius(radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) -> SKShapeNode {
		
		let path = CGMutablePath()
		path.addArc(center: .zero, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)

		let shapeNode = SKShapeNode()
		shapeNode.path = path
		shapeNode.fillColor = .clear
		shapeNode.lineWidth = 0.0
		
		return shapeNode
	}
	
	static func roundedTriangle(width: CGFloat, height: CGFloat, cornderRadius: CGFloat) -> SKShapeNode {
		
		let point1 = CGPoint(x: -width / 2, y: height / 2)
		let point2 = CGPoint(x: 0, y: -height / 2)
		let point3 = CGPoint(x: width / 2, y: height / 2)

		let path = CGMutablePath()
		path.move(to: CGPoint(x: 0, y: height / 2))
		path.addArc(tangent1End: point1, tangent2End: point2, radius: cornderRadius)
		path.addArc(tangent1End: point2, tangent2End: point3, radius: cornderRadius)
		path.addArc(tangent1End: point3, tangent2End: point1, radius: cornderRadius)
		path.closeSubpath()
	
		let shapeNode = SKShapeNode()
		shapeNode.path = path
		shapeNode.fillColor = .clear
		shapeNode.lineWidth = 0.0

		return shapeNode
	}
}

extension GKEntity {
	func component<P>(conformingTo protocol: P.Type) -> P? {
    	for component in components {
	    	if let p = component as? P {
    	    	return p
	    	}
    	}

    	return nil
	}
}
