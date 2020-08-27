//
//  RunningInference.swift
//  BioGenesis
//
//  Created by Robert Silverman on 8/26/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit

class RunningInference {
	
	var memory: Int = 100
	var values: [Inference] = []
		
	init(memory: Int = 100) {
		self.memory = memory
	}
	
	var last: Inference? {
		return values.last
	}
	
	func addValue(_ value: Inference) {
		if values.count == memory {
			values.remove(at: 0)
		}
		values.append(value)
	}
	
	var averageThrust: CGVector {
		
		let memoryCount = values.count
		
		if memoryCount == 0 {
			return .zero
		}
		
		var sum: CGVector = .zero

		values.forEach({
			sum += $0.thrust
		})
		
		return sum/memoryCount.cgFloat
	}
	
	var averageColor: SKColor {
		
		let memoryCount = values.count
		
		if memoryCount == 0 {
			return .white
		}
		
		var sum: ColorVector = .zero
		
		values.forEach({
			sum += $0.color
		})
		
		return (sum/memoryCount.cgFloat).skColor
	}
}
