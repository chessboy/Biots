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

import Foundation
import CoreGraphics

public extension Int {
	/**
	* Ensures that the integer value stays with the specified range.
	*/
	func clamped(_ range: Range<Int>) -> Int {
		return (self < range.lowerBound) ? range.lowerBound : ((self >= range.upperBound) ? range.upperBound - 1: self)
	}
	
	func clamped(_ range: ClosedRange<Int>) -> Int {
		return (self < range.lowerBound) ? range.lowerBound : ((self > range.upperBound) ? range.upperBound: self)
	}
	
	/**
	* Ensures that the integer value stays with the specified range.
	*/
	mutating func clamp(_ range: Range<Int>) -> Int {
		self = clamped(range)
		return self
	}
	
	mutating func clamp(_ range: ClosedRange<Int>) -> Int {
		self = clamped(range)
		return self
	}
	
	/**
	* Ensures that the integer value stays between the given values, inclusive.
	*/
	func clamped(_ v1: Int, _ v2: Int) -> Int {
		let min = v1 < v2 ? v1 : v2
		let max = v1 > v2 ? v1 : v2
		return self < min ? min : (self > max ? max : self)
	}
	
	/**
	* Ensures that the integer value stays between the given values, inclusive.
	*/
	mutating func clamp(_ v1: Int, _ v2: Int) -> Int {
		self = clamped(v1, v2)
		return self
	}
		
	/**
	* Randomly returns either 1.0 or -1.0.
	*/
	static var randomSign: Int {
		return oneChanceIn(2) ? 1 : -1
	}
	
	/**
	* Randomly returns either true or false (weighted)
	*/
	static func oneChanceIn(_ chance: Int) -> Bool {
		return Int.random(in: 0..<chance) == 0 ? true : false
	}
	
	/**
	* Returns a random integer between 0 and n-1.
	*/
	static func random(_ n: Int) -> Int {
		return Int.random(in: 0..<n)
	}
	
	/**
	* Returns a random integer in the range min...max, inclusive.
	*/
	static func random(min: Int, max: Int) -> Int {
		assert(min < max)
		return Int.random(in: min...max)
		//return Int(arc4random_uniform(UInt32(max - min + 1))) + min
	}
	
	var formatted: String { return
		String(format: "%d", locale: Locale.current, self)
	}
}

extension Int {
	var cgFloat: CGFloat { return CGFloat(self) }
}

extension Int {
	// https://stackoverflow.com/questions/18267211/ios-convert-large-numbers-to-smaller-format
	var abbrev: String {
		let numFormatter = NumberFormatter()
		
		typealias Abbrevation = (threshold:Double, divisor:Double, suffix:String)
		let abbreviations:[Abbrevation] = [(0, 1, ""),
										   (1000.0, 1000.0, "K"),
										   (100_000.0, 1_000_000.0, "M"),
										   (100_000_000.0, 1_000_000_000.0, "B")]
		
		let startValue = Double(abs(self))
		let abbreviation: Abbrevation = {
			var prevAbbreviation = abbreviations[0]
			for tmpAbbreviation in abbreviations {
				if (startValue < tmpAbbreviation.threshold) {
					break
				}
				prevAbbreviation = tmpAbbreviation
			}
			return prevAbbreviation
		}()
		
		let value = Double(self) / abbreviation.divisor
		numFormatter.positiveSuffix = abbreviation.suffix
		numFormatter.negativeSuffix = abbreviation.suffix
		numFormatter.allowsFloats = true
		numFormatter.minimumIntegerDigits = 1
		numFormatter.minimumFractionDigits = 0
		numFormatter.maximumFractionDigits = 1
		
		return numFormatter.string(from: NSNumber (value:value))!
	}
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension Int {
	static func timerForAge(_ age: Int, clockRate: Int) -> Float {
		guard clockRate > 0 else { return 0 }
		let period = clockRate/2
		var count = age % clockRate
		count = count > period ? clockRate - count : count
		return Float(count)/Float(period)
	}
}
