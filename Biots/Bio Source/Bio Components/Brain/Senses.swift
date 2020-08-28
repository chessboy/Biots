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
	static let senseInputCount = 11
	
	var health: Float = .zero
	var energy: Float = .zero
	var damage: Float = .zero
	var canMate: Float = .zero
	var pregnant: Float = .zero
	var onTopOfFood: Float = .zero
	var proximityToCenter: Float = .zero
	var angleToCenter: Float = .zero
	var clockShort: Float = .zero
	var clockLong: Float = .zero
	var age: Float = .zero

	mutating func setSenses(
		health: Float,
		energy: Float,
		damage: Float,
		canMate: Float,
		pregnant: Float,
		onTopOfFood: Float,
		proximityToCenter: Float,
		angleToCenter: Float,
		clockShort: Float,
		clockLong: Float,
		age: Float
		) {
		
		self.health = health
		self.energy = energy
		self.damage = damage
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
			health,
			energy,
			damage,
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
