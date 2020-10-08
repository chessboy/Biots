//
//  Inference.swift
//  Biots
//
//  Created by Robert Silverman on 4/24/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation
import OctopusKit
import SpriteKit

enum Interaction: Int, CaseIterable, CustomStringConvertible {
	case attemptToMate = 0
	case attack
	case doNothing
	
	static func fromOutputs(outputs: [Float]) -> Interaction {
		return .doNothing
	}
	
	var description: String {
		return self == .attemptToMate ? "attemptToMate" : self == .attack ? "attack" : "doNothing"
	}
}

struct Inference {
	
	var thrust = RunningCGVector(memory: Constants.Thrust.displayMemory)
	var color = RunningColorVector(memory: Constants.Vision.displayMemory)
	var speedBoost = RunningValue(memory: 5)
	var blink = false
	var armor = RunningValue(memory: 8)
	var seenId: String?
	var interaction: Interaction = .doNothing

	static let minFiringValue: Float = 0.5
	
	/**
	|    0     |     1    |    2    |    3    |    4    |      5      |   6   |   7   |   8  |    9   |
	| L thrust | R thrust | color R | color G | color B | speed boost | blink | armor | mate | attack |
	*/

	static var outputCount: Int {
		return 10
	}
	
	mutating func infer(outputs: [Float], seenId: String? = nil) {

		let count = Inference.outputCount
		guard outputs.count == count else {
			OctopusKit.logForSim.add("outputs count != \(count), count given: \(outputs.count)")
			return
		}
				
		self.seenId = seenId

		// thrust (-1..1, -1..1) x xy
		thrust.addValue(CGVector(dx: outputs[0].cgFloat, dy: outputs[1].cgFloat))
		
		// color (-1..1 --> 0..1) x rgb
		let red = (outputs[2].cgFloat + 1)/2
		let green = (outputs[3].cgFloat + 1)/2
		let blue = (outputs[4].cgFloat + 1)/2
		color.addValue(ColorVector(red: red, green: green, blue: blue))
		
		// speed boost (-1..1 --> 0|1 if > minFiringValue)
		speedBoost.addValue(outputs[5] > Inference.minFiringValue ? 1 : 0)
		
		// blink (-1..1 --> true|false if > minFiringValue)
		blink = outputs[6] > Inference.minFiringValue ? true : false
		
		// armor (-1..1 --> 0|1 if > minFiringValue)
		armor.addValue(outputs[7] > Inference.minFiringValue ? 1 : 0)
				
		if let interactionMax = indexOfMax(of: Array(outputs[8...9]), threshold: Inference.minFiringValue) {
			interaction = Interaction(rawValue: interactionMax) ?? .doNothing
		} else {
			interaction = .doNothing
		}
		
//		if interaction != .doNothing {
//			print()
//		}
	}
	
	func indexOfMax(of outputs: [Float], threshold: Float) -> Int? {
		if let max = outputs.max(), max >= threshold, let index = outputs.firstIndex(of: max) {
			return index
		}
		
		return nil
	}

}
