//
//  Inference.swift
//  SimStarter
//
//  Created by Robert Silverman on 4/24/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation
import OctopusKit
import SpriteKit

struct Inference {
	var detections: [Detection]
	var thrust: CGVector = .zero
	var color: ColorVector = .zero

	static var outputCount: Int {
		return 5
	}
	
	static var zero: Inference {
		let outputs = Array(repeating: Float.zero, count: outputCount)
		return Inference(detections: [], outputs: outputs)
	}
		
	init(detections: [Detection], outputs: [Float]) {
		
		self.detections = detections

		let count = Inference.outputCount
		guard outputs.count == count else {
			OctopusKit.logForSim.add("outputs count != \(count), count given: \(outputs.count)")
			return
		}
		
		thrust = CGVector(dx: outputs[0].cgFloat, dy: outputs[1].cgFloat)
		color = ColorVector(red: outputs[2].cgFloat, green: outputs[3].cgFloat, blue: outputs[4].cgFloat)
	}
	
	func indexOfMax(of outputs: [Float]) -> Int {
		if let max = outputs.max(), let index = outputs.firstIndex(of: max) {
			return index
		}
		
		OctopusKit.logForErrors.add("cannot parse action outputs: \(outputs) for maximum")
		return -1
	}
}
