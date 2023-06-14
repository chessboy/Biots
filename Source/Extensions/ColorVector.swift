//
//  ColorVector.swift
//  Biots
//
//  Created by Robert Silverman on 9/9/18.
//

import Foundation
import OctopusKit
import SpriteKit

public struct ColorVector: Comparable {
	
	public static func < (lhs: ColorVector, rhs: ColorVector) -> Bool {
		return lhs.red + lhs.green + lhs.blue < rhs.red + rhs.green + rhs.blue
	}
	
	public static var zero: ColorVector { return ColorVector() }

	var red: CGFloat = 0
	var green: CGFloat = 0
	var blue: CGFloat = 0
	
	var description: String {
		return "(r:\(red.formattedTo2Places), g:\(green.formattedTo2Places), b:\(blue.formattedTo2Places))"
	}
	
	var skColor: SKColor {
		let safeRed = red.clamped(0, 1)
		let safeGreen = green.clamped(0, 1)
		let safeBlue = blue.clamped(0, 1)
		return SKColor(red: safeRed, green: safeGreen, blue: safeBlue, alpha: 1)
	}
}

//
// adds two ColorVector values and returns the result as a new ColorVector
//
public func + (left: ColorVector, right: ColorVector) -> ColorVector {
	return ColorVector(red: left.red + right.red, green: left.green + right.green, blue: left.blue + right.blue)
}

//
// increments a ColorVector with the value of another
//
public func += (left: inout ColorVector, right: ColorVector) {
	left = left + right
}

//
// subtracts two ColorVector values and returns the result as a new ColorVector
//
public func - (left: ColorVector, right: ColorVector) -> ColorVector {
	return ColorVector(red: left.red - right.red, green: left.green - right.green, blue: left.blue - right.blue)
}

//
// decrements a ColorVector with the value of another
//
public func -= (left: inout ColorVector, right: ColorVector) {
	left = left - right
}

//
// multiplies two ColorVector values and returns the result as a new ColorVector
//
public func * (left: ColorVector, right: ColorVector) -> ColorVector {
	return ColorVector(red: left.red * right.red, green: left.green * right.green, blue: left.blue * right.blue)
}

//
// multiplies a ColorVector with another
//
public func *= (left: inout ColorVector, right: ColorVector) {
	left = left * right
}

//
// multiplies the r, g and b fields of a ColorVector with the same scalar value and returns the result as a new ColorVector
//
public func * (vector: ColorVector, scalar: CGFloat) -> ColorVector {
	return ColorVector(red: vector.red * scalar, green: vector.green * scalar, blue: vector.blue * scalar)
}

//
// multiplies the r, g and b fields of a ColorVector with the same scalar value
//
public func *= (vector: inout ColorVector, scalar: CGFloat) {
	vector = vector * scalar
}

//
// divides two ColorVector values and returns the result as a new ColorVector
//
public func / (left: ColorVector, right: ColorVector) -> ColorVector {
	return ColorVector(red: left.red / right.red, green: left.green / right.green, blue: left.blue / right.blue)
}

//
// divides a ColorVector by another
//
public func /= (left: inout ColorVector, right: ColorVector) {
	left = left / right
}

//
// divides the r, g and b fields of a ColorVector by the same scalar value and returns the result as a new ColorVector
//
public func / (vector: ColorVector, scalar: CGFloat) -> ColorVector {
	return ColorVector(red: vector.red / scalar, green: vector.green / scalar, blue: vector.blue / scalar)
}

//
// divides the r, g and b fields of a ColorVector by the same scalar value
//
public func /= (vector: inout ColorVector, scalar: CGFloat) {
	vector = vector / scalar
}

//
// divides the r, g and b fields of a ColorVector by the same scalar value
//
public func /= (vector: inout ColorVector, scalar: Int) {
	vector = vector / scalar.cgFloat
}
