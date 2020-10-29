//
//  CGPointMath.swift
//  Biots
//
//  Created by Robert Silverman on 4/12/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation

public extension CGPoint {
	/**
	* Creates a new CGPoint given a CGVector.
	*/
	init(vector: CGVector) {
		self.init(x: vector.dx, y: vector.dy)
	}
	
	/**
	* Given an angle in radians, creates a vector of length 1.0 and returns the
	* result as a new CGPoint. An angle of 0 is assumed to point to the right.
	*/
	init(angle: CGFloat) {
		self.init(x: cos(angle), y: sin(angle))
	}
	
	// converter
	var vector: CGVector {
		return CGVector(dx: x, dy: y)
	}
	
	/**
	* Adds (dx, dy) to the point.
	*/
	mutating func offset(dx: CGFloat, dy: CGFloat) -> CGPoint {
		x += dx
		y += dy
		return self
	}
	
	/**
	* Returns the length (magnitude) of the vector described by the CGPoint.
	*/
	func length() -> CGFloat {
		return sqrt(x*x + y*y)
	}
	
	/**
	* Returns the squared length of the vector described by the CGPoint.
	*/
	func lengthSquared() -> CGFloat {
		return x*x + y*y
	}
	
	/**
	* Normalizes the vector described by the CGPoint to length 1.0 and returns
	* the result as a new CGPoint.
	*/
	func normalized() -> CGPoint {
		let len = length()
		return len>0 ? self / len : CGPoint.zero
	}
	
	/**
	* Normalizes the vector described by the CGPoint to length 1.0.
	*/
	mutating func normalize() -> CGPoint {
		self = normalized()
		return self
	}
	
	/**
	* Calculates the distance between two CGPoints. Pythagoras!
	*/
	func distanceTo(_ point: CGPoint) -> CGFloat {
		let difference = CGPoint(x: self.x - point.x, y: self.y - point.y)
		return difference.length()
	}
	
	/**
	* Returns the angle in radians of the vector described by the CGPoint.
	* The range of the angle is -π to π; an angle of 0 points to the right.
	*/
	var angle: CGFloat {
		return atan2(y, x)
	}
	
	static var randomAngle: CGPoint {
		return CGPoint(angle: CGFloat.randomAngle)
	}
	
	static func randomDistance(_ distance: CGFloat) -> CGPoint {
		return randomAngle * distance
	}
	
	var formattedTo2Places: String { return
		"(\(x.formattedTo2Places), \(y.formattedTo2Places))"
	}
}

extension CGSize {
	var formattedTo2Places: String { return
		"(\(width.formattedTo2Places), \(height.formattedTo2Places))"
	}
}

extension CGVector {
	var formattedTo2Places: String { return
		"(\(dx.formattedTo2Places), \(dy.formattedTo2Places))"
	}
}
