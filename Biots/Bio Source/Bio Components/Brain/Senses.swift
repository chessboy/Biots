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
	static let newInputCount = 14
	
	var inputCount: Int
	var marker1: Float = .zero
	var marker2: Float = .zero
	var health: Float = .zero
	var energy: Float = .zero
	var stamina: Float = .zero
	var canMate = RunningValue(memory: 9)
	var pregnant = RunningValue(memory: 9)
	var onTopOfFood = RunningValue(memory: 3)
	var visibility: Float = .zero
	var proximityToCenter: Float = .zero
	var angleToCenter: Float = .zero
	var clockShort: Float = .zero
	var clockLong: Float = .zero
	var age: Float = .zero

	init(inputCount: Int) {
		self.inputCount = inputCount
	}
	
	mutating func setSenses(
		marker1: Float,
		marker2: Float,
		health: Float,
		energy: Float,
		stamina: Float,
		canMate: Float,
		pregnant: Float,
		onTopOfFood: Float,
		visibility: Float,
		proximityToCenter: Float,
		angleToCenter: Float,
		clockShort: Float,
		clockLong: Float,
		age: Float
		) {
		
		self.marker1 = marker1
		self.marker2 = marker2
		self.health = health
		self.energy = energy
		self.stamina = stamina
		self.canMate.addValue(canMate)
		self.pregnant.addValue(pregnant)
		self.onTopOfFood.addValue(onTopOfFood)
		self.visibility = visibility
		self.proximityToCenter = proximityToCenter
		self.angleToCenter = angleToCenter
		self.clockShort = clockShort
		self.clockLong = clockLong
		self.age = age
	}
	
	var toArray: [Float] {
				
		var inputs: [Float] = []
		
		if inputCount == 32 {
			inputs = [
				marker1,
				marker2,
				health,
				energy,
				stamina,
				canMate.average,
				pregnant.average,
				proximityToCenter,
				angleToCenter,
				onTopOfFood.average,
				visibility,
				clockShort,
				clockLong,
				age
			]
		}
		else if inputCount == 28 {
			inputs = [
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
		
		return inputs
	}
}
