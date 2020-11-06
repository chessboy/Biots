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
	
	func valueForGeneration(_ generation: Int, generationThreshold: Int) -> CGFloat {
		
		if generation >= generationThreshold {
			return end
		}
		
		let percentage = generation.cgFloat / generationThreshold.cgFloat
		return start + percentage * (end-start)
	}
	
	var description: String {
		return "{start: \(start), end: \(end)}"
	}
}

enum ConfigParam: Int {
	case maximumAge = 0

	// requirements
	case mateHealth
	case spawnHealth
	case maximumFoodEnergy
	case maximumHydration

	// costs
	case collisionDamage
	case perMovementStaminaRecovery
	case perMovementHydrationCost
	case perMovementEnergyCost
	case speedBoostStaminaCost
	case armorEnergyCost
}

struct GameConfig: CustomStringConvertible {
	
	var name: String
	var gameMode: GameMode
	var algaeTarget: Int
	var worldBlockCount: Int
	var worldRadius: CGFloat = .zero
	var minimumBiotCount: Int = 0
	var maximumBiotCount: Int = 0

	var worldObjects: [WorldObject] = []
	var genomes: [Genome] = []
	
	// environmental
	let dampeningWater: CGFloat = 0.2
	let biotCarcasesArePowerFood = true
	let environmentalPressureGenerationalThreshold = 200
	let clockRate = 60 // ticks per 1-way cycle

	var biotParams: [ConfigParam : BiotParam] = [
		// age
		.maximumAge : BiotParam(start: 2280, end: 3300),
		
		// requirements
		.mateHealth : BiotParam(start: 0.65, end: 0.8),
		.spawnHealth : BiotParam(start: 0.55, end: 0.75),
		.maximumFoodEnergy : BiotParam(start: 80, end: 120),
		.maximumHydration : BiotParam(start: 80, end: 120),

		// costs
		.collisionDamage : BiotParam(start: 0.10, end: 0.25),
		.perMovementStaminaRecovery : BiotParam(start: 0.0015, end: 0.00125),
		.perMovementHydrationCost : BiotParam(start: 0.0075, end: 0.01),
		.perMovementEnergyCost : BiotParam(start: 0.0075, end: 0.0125),
		.speedBoostStaminaCost : BiotParam(start: 0.0006, end: 0.0008),
		.armorEnergyCost : BiotParam(start: 0.04, end: 0.06)
	]

	init(gameMode: GameMode) {
		self.gameMode = gameMode
		name = "Random"
		worldBlockCount = 13
		algaeTarget = 0

		if gameMode != .debug {
			worldObjects = DataManager.shared.loadWorldObjects(type: .less)
			algaeTarget = 15000
		}
		
		minimumBiotCount = 10
		maximumBiotCount = 22

		setup()
	}
	
	var description: String {
		
		let minGen = genomes.map({$0.generation}).min() ?? 0
		let maxGen = genomes.map({$0.generation}).max() ?? 0

		return "{name: \(name), gameMode: \(gameMode.description), algaeTarget: \(algaeTarget), worldBlockCount: \(worldBlockCount), worldRadius: \(worldRadius.formattedNoDecimal), worldObjects: \(worldObjects.count), genomes: \(genomes.count), generations: \(minGen.abbrev)–\(maxGen.abbrev), biotCounts: \(minimumBiotCount)...\(maximumBiotCount)}"
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
	
	func valueForConfig(_ configParam: ConfigParam, generation: Int) -> CGFloat {
		if let biotParam = biotParams[configParam] {
			return biotParam.valueForGeneration(generation, generationThreshold: environmentalPressureGenerationalThreshold)
		}
		
		OctopusKit.logForSimWarnings.add("unknown configParam: \(configParam.rawValue)")
		return 0
	}
}
