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
	var onTopOfMud = RunningValue(memory: 3)
	var progress: Float = .zero
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
		onTopOfMud: Float,
		progress: Float,
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
		self.onTopOfMud.addValue(onTopOfMud)
		self.clockShort = clockShort
		self.clockLong = clockLong
		self.age = age
	}
	
	var toArray: [Float] {
		
		if inputCount == 28 {
			return [
				health,
				energy,
				hydration,
				stamina,
				pregnant.average,
				onTopOfFood.average,
				onTopOfWater.average,
				clockShort,
				clockLong,
				age
			]
		} else if inputCount == 30 {
			return [
				health,
				energy,
				hydration,
				stamina,
				pregnant.average,
				onTopOfFood.average,
				onTopOfWater.average,
				onTopOfMud.average,
				progress,
				clockShort,
				clockLong,
				age
			]
		}

		return []
	}
}
