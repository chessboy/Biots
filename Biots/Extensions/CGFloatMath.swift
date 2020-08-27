//
//  CGFloatmath.swift
//  BioGenesis
//
//  Created by Robert Silverman on 4/12/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation

extension CGFloat {

	/* Ensures that the float value stays between the given values, inclusive.
	*/
	func clamped(_ v1: CGFloat, _ v2: CGFloat) -> CGFloat {
		let min = v1 < v2 ? v1 : v2
		let max = v1 > v2 ? v1 : v2
		return self < min ? min : (self > max ? max : self)
	}
	
	/**
	* Ensures that the float value stays between the given values, inclusive.
	*/
	mutating func clamp(_ v1: CGFloat, _ v2: CGFloat) -> CGFloat {
		self = clamped(v1, v2)
		return self
	}
	
	/**
	* Returns 1.0 if a floating point value is positive; -1.0 if it is negative.
	*/
	func sign() -> CGFloat {
		return (self >= 0.0) ? 1.0 : -1.0
	}
	
	var unsigned: CGFloat {
		return abs(self)
	}
	
	var sigmoid: CGFloat {
		return 1 / (1 + exp(-self))
	}
	
	var float: Float { return Float(self) }
	
	var degrees: CGFloat {
		return self * 180/π
	}
	
	var radians: CGFloat {
		return self * π/180
	}
	
	static var randomAngle: CGFloat {
		return CGFloat(random(in: 0..<2*π))
	}
	
	var formattedNoDecimal: String { return
		String(format: "%.0f", locale: Locale.current, self)
	}

	var formatted: String { return
		String(format: "%.1f", locale: Locale.current, self)
	}

	var formattedTo2Places: String { return
		String(format: "%.2f", locale: Locale.current, self)
	}

	var formattedTo3Places: String { return
		String(format: "%.3f", locale: Locale.current, self)
	}

	var formattedTo4Places: String { return
		String(format: "%.4f", locale: Locale.current, self)
	}

	var formattedToPercent: String { return
		String(format: "%.1f", locale: Locale.current, self.clamped(0.0, 1.0) * 100.0) + "%"
	}

	var formattedToPercentNoDecimal: String { return
		String(format: "%.0f", locale: Locale.current, self.clamped(0.0, 1.0) * 100.0) + "%"
	}
	
	// 0 <= normalized <= 360
	var normalizedAngle: CGFloat {
		var angle = fmod(self, 2*π)
		if (angle < 0) {
			angle += 2*π
		}
		if angle == -0 {
			angle = 0
		}
		return angle
	}
}

extension Float {
	
	var formattedTo2Places: String { return
		String(format: "%.2f", locale: Locale.current, self)
	}
	
	var cgFloat: CGFloat { return CGFloat(self) }
	
	var unsigned: Float { return abs(self) }
	
	var sigmoid: Float {
		return 1 / (1 + exp(-self))
	}
	
	var sigmoidBool: Float {
		return sigmoid >= 0.5 ? 1 : 0
	}
}
