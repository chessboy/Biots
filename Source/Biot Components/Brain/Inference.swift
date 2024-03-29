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

struct Inference {
	
	var thrust = RunningCGVector(memory: Constants.Thrust.displayMemory)
	var color = RunningColorVector(memory: Constants.Vision.displayMemory)
	var speedBoost = RunningValue(memory: 5)
	var armor = RunningValue(memory: 8)
	var weapon = RunningValue(memory: 8)

	static let minFiringValue: Float = 0.5
	
	/**
	|    0     |     1    |    2    |    3    |    4    |      5      |    6   |   7   |
	| L thrust | R thrust | color R | color G | color B | speed boost | weapon | armor |
	*/

	static var outputCount: Int {
		return 8
	}
	
	var constrainedWeaponAverage: CGFloat {
		let armorAverage = armor.average
		let weaponAverage = weapon.average

		return (weaponAverage - armorAverage).cgFloat.clamped(0, 1)
	}
	
	mutating func infer(outputs: [Float]) {

		let count = Inference.outputCount
		guard outputs.count == count else {
			OctopusKit.logForSimInfo.add("outputs count != \(count), count given: \(outputs.count)")
			return
		}
	
		// thrust (-1..1, -1..1) x xy
		thrust.addValue(CGVector(dx: outputs[0].cgFloat, dy: outputs[1].cgFloat))
		
		// color (-1..1 --> 0..1) x rgb
		let red = (outputs[2].cgFloat + 1)/2
		let green = (outputs[3].cgFloat + 1)/2
		let blue = (outputs[4].cgFloat + 1)/2
		color.addValue(ColorVector(red: red, green: green, blue: blue))
		
		// speed boost (-1..1 --> 0|1 if > minFiringValue)
		speedBoost.addValue(outputs[5] > Inference.minFiringValue ? 1 : 0)
		
		// weapon (-1..1 --> 0|1 if > minFiringValue)
		weapon.addValue(outputs[6] > Inference.minFiringValue ? 1 : 0)

		// armor (-1..1 --> 0|1 if > minFiringValue)
		armor.addValue(outputs[7] > Inference.minFiringValue ? 1 : 0)
	}
}
