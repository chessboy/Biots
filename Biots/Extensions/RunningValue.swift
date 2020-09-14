//
//  RunningValue.swift
//  SwiftBots
//
//  Created by Robert Silverman on 9/19/18.
//  Copyright © 2018 fep. All rights reserved.
//

import Foundation

class RunningValue {
	
	var memory: Int = 100
	var values: [Float] = []
	var decayedSum: Float = 0
		
	init(memory: Int = 100) {
		self.memory = memory
	}
	
	func addValue(_ value: Float) {
		if values.count == memory {
			values.remove(at: 0)
		}
		values.append(value)
		
		decayedSum += value
	}
	
	var sum: Float {
		var sum: Float = 0
		values.forEach({ sum += $0 })
		return sum
	}
	
	var average: Float {
		return values.count == 0 ? 0 : sum / Float(values.count)
	}
	
	func averageOfMostRecent(memory: Int) -> Float {
		
		guard values.count > 0 else { return 0 }
		guard values.count > 1 else { return values[0] }
		guard values.count > memory else { return average }

		// there are more than `memory` values
		let suffix = values.count - memory
		let memoryValues = values.suffix(from: suffix)
		var sum: Float = 0
		memoryValues.forEach({ sum += $0 })
		
		return sum / Float(memoryValues.count)
	}

	func decay(by amount: Float = 0.9) {
		decayedSum *= amount
	}
}
