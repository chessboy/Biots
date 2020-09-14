//
//  RunningCGVector.swift
//  Biots
//
//  Created by Robert Silverman on 8/29/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation
import OctopusKit

class RunningCGVector {

	var memory: Int = 100
	var values: [CGVector] = []
	var decayedSum: CGVector = .zero
	
	init(memory: Int = 100) {
		self.memory = memory
	}
	
	func addValue(_ value: CGVector) {
		if values.count == memory {
			values.remove(at: 0)
		}
		values.append(value)
		
		decayedSum += value
	}
	
	var sum: CGVector {
		var sum: CGVector = .zero
		values.forEach({ sum += $0 })
		return sum
	}
	
	var average: CGVector {
		return values.count == 0 ? .zero : sum / CGFloat(values.count)
	}
	
	func averageOfMostRecent(memory: Int) -> CGVector {
		
		guard values.count > 0 else { return .zero }
		guard values.count > 1 else { return values[0] }
		guard values.count > memory else { return average }

		// there are more than `memory` values
		let suffix = values.count - memory
		let memoryValues = values.suffix(from: suffix)
		var sum: CGVector = .zero
		memoryValues.forEach({ sum += $0 })
		
		return sum / CGFloat(memoryValues.count)
	}

	func decay(by amount: CGFloat = 0.9) {
		decayedSum *= amount
	}
}
