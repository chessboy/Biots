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
	static let inputCount = 10
	
	var health: Float = .zero
	var energy: Float = .zero
	var stamina: Float = .zero
	var canMate = RunningValue(memory: 9)
	var pregnant = RunningValue(memory: 9)
	var onTopOfFood = RunningValue(memory: 3)
	var visibility: Float = .zero
	var clockShort: Float = .zero
	var clockLong: Float = .zero
	var age: Float = .zero

	mutating func setSenses(
		health: Float,
		energy: Float,
		stamina: Float,
		canMate: Float,
		pregnant: Float,
		onTopOfFood: Float,
		visibility: Float,
		clockShort: Float,
		clockLong: Float,
		age: Float
		) {
		
		self.health = health
		self.energy = energy
		self.stamina = stamina
		self.canMate.addValue(canMate)
		self.pregnant.addValue(pregnant)
		self.onTopOfFood.addValue(onTopOfFood)
		self.visibility = visibility
		self.clockShort = clockShort
		self.clockLong = clockLong
		self.age = age
	}
	
	var toArray: [Float] {
				
		return [
			health,
			energy,
			stamina,
			canMate.average,
			pregnant.average,
			onTopOfFood.average,
			visibility,
			clockShort,
			clockLong,
			age
		]
	}
}
