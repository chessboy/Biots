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
	static let inputCount = 12
	
	var marker1: Float = .zero
	var health: Float = .zero
	var energy: Float = .zero
	var stamina: Float = .zero
	var canMate: Float = .zero
	var pregnant: Float = .zero
	var onTopOfFood: Float = .zero
	var proximityToCenter: Float = .zero
	var angleToCenter: Float = .zero
	var clockShort: Float = .zero
	var clockLong: Float = .zero
	var age: Float = .zero

	mutating func setSenses(
		marker1: Float,
		health: Float,
		energy: Float,
		stamina: Float,
		canMate: Float,
		pregnant: Float,
		onTopOfFood: Float,
		proximityToCenter: Float,
		angleToCenter: Float,
		clockShort: Float,
		clockLong: Float,
		age: Float
		) {
		
		self.marker1 = marker1
		self.health = health
		self.energy = energy
		self.stamina = stamina
		self.canMate = canMate
		self.pregnant = pregnant
		self.onTopOfFood = onTopOfFood
		self.proximityToCenter = proximityToCenter
		self.angleToCenter = angleToCenter
		self.clockShort = clockShort
		self.clockLong = clockLong
		self.age = age
	}
	
	var toArray: [Float] {
				
		return [
			marker1,
			health,
			energy,
			stamina,
			canMate,
			pregnant,
			proximityToCenter,
			angleToCenter,
			onTopOfFood,
			clockShort,
			clockLong,
			age
		]
	}
}
