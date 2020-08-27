//
//  RunningFloatArray.swift
//  Biots
//
//  Created by Robert Silverman on 8/19/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import OctopusKit

class RunningFloatArray {

	var floatValues: [RunningValue] = []
	
	init(size: Int, memory: Int) {
		for _ in 0..<size {
			floatValues.append(RunningValue(memory: memory))
		}
	}
	
	func addFloats(_ floats: [Float]) {
		guard floats.count == floatValues.count else {
			OctopusKit.logForSim.add("floats count != \(floatValues.count), count given: \(floats.count)")
			return
		}
		
		for index in 0..<floats.count {
			floatValues[index].addValue(floats[index])
		}
	}
	
	var average: [Float] {
		return floatValues.map { $0.average }
	}
}
