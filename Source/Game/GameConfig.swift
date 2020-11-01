//
//  GameConfig.swift
//  Biots
//
//  Created by Rob Silverman on 10/28/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation
import OctopusKit

struct BiotParam: CustomStringConvertible {
	var start: CGFloat
	var end: CGFloat
	static let generationThreshold = Constants.Biot.environmentalPressureGenerationalThreshold.cgFloat
	
	func valueForGeneration(_ generation: Int) -> CGFloat {
		let percentage = (generation.cgFloat/BiotParam.generationThreshold).clamped(0, 1)
		return start + percentage * (end-start)
	}
	
	var description: String {
		return "{start: \(start), end: \(end)}"
	}
}

struct GameConfig: CustomStringConvertible {
	
	var name: String
	var gameMode: GameMode
	var algaeTarget: Int
	var worldBlockCount: Int
	var worldRadius: CGFloat = .zero
	var worldObjects: [WorldObject] = []
	var genomes: [Genome] = []
	
	var minimumBiotCount: Int = 0
	var maximumBiotCount: Int = 0
	
	let collisionDamage = BiotParam(start: 0.15, end: 0.25)
	let perMovementRecovery = BiotParam(start: 0.0015, end: 0.00125)
	let perMovementHydrationCost = BiotParam(start: 0.0075, end: 0.01)

	let mateHealth = BiotParam(start: 0.7, end: 0.8)
	let spawnHealth = BiotParam(start: 0.6, end: 0.75)
	let maximumAge = BiotParam(start: 2000, end: 3200)
	
	let maximumFoodEnergy = BiotParam(start: 100, end: 120)
	let maximumHydration = BiotParam(start: 85, end: 100)

	let perMovementEnergyCost = BiotParam(start: 0.0075, end: 0.0125)
	let speedBoostStaminaCost = BiotParam(start: 0.0006, end: 0.0008)
	let armorEnergyCost = BiotParam(start: 0.04, end: 0.06)

	let clockRate = 60 // ticks per 1-way cycle
	let dampeningWater: CGFloat = 0.2
	
	init(gameMode: GameMode) {
		self.gameMode = gameMode
		name = "Untitled"
		worldBlockCount = 10
		algaeTarget = 0

		if gameMode != .debug {
			worldObjects = DataManager.shared.loadWorldObjects(type: .less)
			algaeTarget = 10000
		}
		
		minimumBiotCount = 12
		maximumBiotCount = 24

		setup()
	}
	
	var description: String {
		return "{name: \(name), gameMode: \(gameMode.description), algaeTarget: \(algaeTarget), worldBlockCount: \(worldBlockCount), worldRadius: \(worldRadius.formattedNoDecimal), worldObjects: \(worldObjects.count), genomes: \(genomes.count), biotCounts: \(minimumBiotCount)...\(maximumBiotCount)}"
	}

	
	init(saveState: SaveState) {
		name = saveState.name
		gameMode = saveState.gameMode
		algaeTarget = saveState.algaeTarget
		worldBlockCount = saveState.worldBlockCount
		self.worldObjects = saveState.worldObjects
		self.genomes = saveState.genomes
		self.minimumBiotCount = saveState.minimumBiotCount
		self.maximumBiotCount = saveState.maximumBiotCount
		setup()
	}
	
	mutating func setup() {
		worldRadius = Constants.Env.gridBlockSize * worldBlockCount.cgFloat
		
		OctopusKit.logForSimInfo.add("new config: \(description)")
	}
}
