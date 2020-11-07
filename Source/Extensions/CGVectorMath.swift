/*
* Copyright (c) 2013-2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import CoreGraphics
import SpriteKit
import OctopusKit

public extension CGVector {
	/**
	* Creates a new CGVector given a CGPoint.
	*/
	init(point: CGPoint) {
		self.init(dx: point.x, dy: point.y)
	}
	
	/**
	* Given an angle in radians, creates a vector of length 1.0 and returns the
	* result as a new CGVector. An angle of 0 is assumed to point to the right.
	*/
	init(angle: CGFloat) {
		self.init(dx: cos(angle), dy: sin(angle))
	}
	
	// converter
	var point: CGPoint {
		return CGPoint(x: dx, y: dy)
	}
	
	/**
	* Adds (dx, dy) to the vector.
	*/
	mutating func offset(dx: CGFloat, dy: CGFloat) -> CGVector {
		self.dx += dx
		self.dy += dy
		return self
	}
	
	/**
	* Returns the length (magnitude) of the vector described by the CGVector.
	*/
	func length() -> CGFloat {
		return sqrt(dx*dx + dy*dy)
	}
	
	/**
	* Returns the squared length of the vector described by the CGVector.
	*/
	func lengthSquared() -> CGFloat {
		return dx*dx + dy*dy
	}
	
	/**
	* Normalizes the vector described by the CGVector to length 1.0 and returns
	* the result as a new CGVector.
	public  */
	func normalized() -> CGVector {
		let len = length()
		return len>0 ? self / len : CGVector.zero
	}
	
	/**
	* Normalizes the vector described by the CGVector to length 1.0.
	*/
	mutating func normalize() -> CGVector {
		self = normalized()
		return self
	}
	
	/**
	* Calculates the distance between two CGVectors. Pythagoras!
	*/
	func distanceTo(_ vector: CGVector) -> CGFloat {
		return (self - vector).length()
	}
	
	/**
	* Returns the angle in radians of the vector described by the CGVector.
	* The range of the angle is -π to π; an angle of 0 points to the right.
	*/
	var angle: CGFloat {
		return atan2(dy, dx)
	}
	
	var description: String {
		return "(\(dx.formattedTo2Places), \(dy.formattedTo2Places))"
	}
}
