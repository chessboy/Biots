//
//  SpriteKitExtensions.swift
//  Biots
//
//  Created by Robert Silverman on 4/13/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreGraphics
import OctopusKit

extension SKShapeNode {
	
	static func polygonOfRadius(_ radius: CGFloat, sides: Int) -> SKShapeNode {
		
		var points: [CGPoint] = []
		
		let startAngle = 2*π / sides.cgFloat/2
		
		for i in 0...sides {
			let rotationFactor = ((2*π) / sides.cgFloat) * (i.cgFloat) + startAngle
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
		shapeNode.lineWidth = 0
		
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
		shapeNode.lineWidth = 0

		return shapeNode
	}
	
	static func polygonOfRadius(_ radius: CGFloat, sides: Int, cornerRadius: CGFloat = 0, lineWidth: CGFloat = 0, rotationOffset: CGFloat = 0) -> SKShapeNode {
		
		let path = CGPath.roundedPolygonPath(radius: radius, lineWidth: lineWidth, sides: sides, cornerRadius: cornerRadius, rotationOffset: rotationOffset)
		
		guard sides > 2 else {
			OctopusKit.logForSimErrors.add("cannot make a polygon with less than 3 sides, here's a circle")
			return SKShapeNode(circleOfRadius: radius)
		}

		let shapeNode = SKShapeNode()
		shapeNode.path = path
		shapeNode.fillColor = .clear
		shapeNode.lineWidth = 0

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

extension CGPath {
	
	// http://sapandiwakar.in/make-hexagonal-view-on-ios/
	static func roundedPolygonPath(radius: CGFloat, lineWidth: CGFloat, sides: Int, cornerRadius: CGFloat, rotationOffset: CGFloat = 0) -> CGPath {
		
		let path = CGMutablePath()
		let theta: CGFloat = 2*π/sides.cgFloat

		// Radius of the circle that encircles the polygon
		// Notice that the radius is adjusted for the corners, that way the largest outer
		// dimension of the resulting shape is always exactly the width - linewidth
		//let radius´ = (radius - lineWidth + cornerRadius - (cos(theta) * cornerRadius))

		// Start drawing at a point, which by default is at the right hand edge, but can be offset
		var angle = CGFloat(rotationOffset)

		let corner = CGPoint(x: (radius - cornerRadius) * cos(angle), y: (radius - cornerRadius) * sin(angle))
		path.move(to: CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta)))

		for _ in 0..<sides {
			angle += theta

			let corner = CGPoint(x: (radius - cornerRadius) * cos(angle), y: (radius - cornerRadius) * sin(angle))
			let tip = CGPoint(x: radius * cos(angle), y: radius * sin(angle))
			let start = CGPoint(x: corner.x + cornerRadius * cos(angle - theta), y: corner.y + cornerRadius * sin(angle - theta))
			let end = CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta))

			path.addLine(to: start)
			path.addQuadCurve(to: end, control: tip)
		}

		path.closeSubpath()

		return path
	}
}

extension SKAction {
	
	// based on OctopusKit extension but allows for independent on and off times
    public class func flash(onDuration: TimeInterval = 0.2, offDuration: TimeInterval = 0.1) -> SKAction {
		let flashOff = SKAction.hide()
		let flashOn = SKAction.unhide()
		let flashOffOn = SKAction.sequence([flashOff, SKAction.wait(forDuration: offDuration), flashOn, SKAction.wait(forDuration: onDuration)])
		return SKAction.sequence([flashOn, flashOffOn])
	}
}

extension SKScene {
	func viewSizeInLocalCoordinates() -> CGRect {
		let min = convertPoint(fromView: CGPoint(x: view!.bounds.minX, y: view!.bounds.minY))
		let max = convertPoint(fromView: CGPoint(x: view!.bounds.maxX, y: view!.bounds.maxY))
		let delta = max - min
		return CGRect(x: min.x , y: min.y, width: delta.x, height: delta.y)
	}
}
