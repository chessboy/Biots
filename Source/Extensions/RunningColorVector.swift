//
//  RunningColorVector.swift
//  Biots
//
//  Created by Robert Silverman on 9/21/18.
//

import Foundation

class RunningColorVector {
	
	var memory: Int = 100
	var values: [ColorVector] = []
	var decayedSum: ColorVector = .zero
	
	init(memory: Int = 100) {
		self.memory = memory
	}
	
	func addValue(_ value: ColorVector) {
		if values.count == memory {
			values.remove(at: 0)
		}
		values.append(value)
		
		decayedSum += value
	}
	
	var sum: ColorVector {
		var sum: ColorVector = .zero
		values.forEach({ sum += $0 })
		return sum
	}
	
	var average: ColorVector {
		return values.count == 0 ? .zero : sum / CGFloat(values.count)
	}
	
	var maximum: ColorVector {
		guard values.count > 0 else { return .zero }
		guard values.count > 1 else { return values[0] }

		var maxRed: CGFloat = .zero
		var maxGreen: CGFloat = .zero
		var maxBlue: CGFloat = .zero
		
		values.forEach({ colorVector in
			maxRed = max(colorVector.red, maxRed)
			maxGreen = max(colorVector.green, maxGreen)
			maxBlue = max(colorVector.blue, maxBlue)
		})
		
		return ColorVector(red: maxRed, green: maxGreen, blue: maxBlue)
	}
	
	func averageOfMostRecent(memory: Int) -> ColorVector {
		
		guard values.count > 0 else { return .zero }
		guard values.count > 1 else { return values[0] }
		guard values.count > memory else { return average }

		// there are more than `memory` values
		let suffix = values.count - memory
		let memoryValues = values.suffix(from: suffix)
		var sum: ColorVector = .zero
		memoryValues.forEach({ sum += $0 })
		
		return memoryValues.count == 0 ? .zero : sum / CGFloat(memoryValues.count)
	}
	
	func maxOfMostRecent(memory: Int) -> ColorVector {
		
		guard values.count > 0 else { return .zero }
		guard values.count > 1 else { return values[0] }
		guard values.count > memory else { return maximum }

		// there are more than `memory` values
		let suffix = values.count - memory
		let memoryValues = values.suffix(from: suffix)

		var maxRed: CGFloat = .zero
		var maxGreen: CGFloat = .zero
		var maxBlue: CGFloat = .zero
		
		memoryValues.forEach({ colorVector in
			maxRed = max(colorVector.red, maxRed)
			maxGreen = max(colorVector.green, maxGreen)
			maxBlue = max(colorVector.blue, maxBlue)
		})
		
		return ColorVector(red: maxRed, green: maxGreen, blue: maxBlue)
	}

	func decay(by amount: CGFloat = 0.9) {
		decayedSum *= amount
	}
}
