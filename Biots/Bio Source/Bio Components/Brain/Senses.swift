//
//  Senses.swift
//  Biots
//
//  Created by Robert Silverman on 4/24/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation
import OctopusKit

struct Senses {
	static let newInputCount = 12
	
	var inputCount: Int
	
	var health: Float = .zero
	var energy: Float = .zero
	var hydration: Float = .zero
	var stamina: Float = .zero
	var pregnant = RunningValue(memory: 5)
	var onTopOfFood = RunningValue(memory: 3)
	var onTopOfWater = RunningValue(memory: 3)
	var visibility: Float = .zero
	var proximityToCenter: Float = .zero
	var clockShort: Float = .zero
	var clockLong: Float = .zero
	var age: Float = .zero

	init(inputCount: Int) {
		self.inputCount = inputCount
	}
	
	mutating func setSenses(
		health: Float,
		energy: Float,
		hydration: Float,
		stamina: Float,
		pregnant: Float,
		onTopOfFood: Float,
		onTopOfWater: Float,
		visibility: Float,
		proximityToCenter: Float,
		clockShort: Float,
		clockLong: Float,
		age: Float
		) {
		
		self.health = health
		self.energy = energy
		self.hydration = hydration
		self.stamina = stamina
		self.pregnant.addValue(pregnant)
		self.onTopOfFood.addValue(onTopOfFood)
		self.onTopOfWater.addValue(onTopOfWater)
		self.visibility = visibility
		self.proximityToCenter = proximityToCenter
		self.clockShort = clockShort
		self.clockLong = clockLong
		self.age = age
	}
	
	var toArray: [Float] {
		
		return [
			health,
			energy,
			hydration,
			stamina,
			pregnant.average,
			proximityToCenter,
			onTopOfFood.average,
			onTopOfWater.average,
			visibility,
			clockShort,
			clockLong,
			age
		]
	}
}
