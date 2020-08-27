//
//  Senses.swift
//  SimStarter
//
//  Created by Robert Silverman on 4/24/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation
import OctopusKit

struct Senses {
	static let senseInputCount = 12
	
	var gender: Float = .zero
	var pregnant: Float = .zero
	var canMate: Float = .zero
	var health: Float = .zero
	var energy: Float = .zero
	var damage: Float = .zero
	var onTopOfFood: Float = .zero
	var proximityToCenter: Float = .zero
	var angleToCenter: Float = .zero
	var clockShort: Float = .zero
	var clockLong: Float = .zero
	var age: Float = .zero

	mutating func setSenses(
		gender: Float,
		pregnant: Float,
		canMate: Float,
		health: Float,
		energy: Float,
		damage: Float,
		onTopOfFood: Float,
		proximityToCenter: Float,
		angleToCenter: Float,
		clockShort: Float,
		clockLong: Float,
		age: Float
		) {
		
		self.gender = gender
		self.pregnant = pregnant
		self.canMate = canMate
		self.health = health
		self.energy = energy
		self.damage = damage
		self.onTopOfFood = onTopOfFood
		self.proximityToCenter = proximityToCenter
		self.angleToCenter = angleToCenter
		self.clockShort = clockShort
		self.clockLong = clockLong
		self.age = age
	}
	
	var toArray: [Float] {
				
		return [
			gender,
			pregnant,
			canMate,
			health,
			proximityToCenter,
			angleToCenter,
			energy,
			damage,
			onTopOfFood,
			clockShort,
			clockLong,
			age
		]
	}
}
