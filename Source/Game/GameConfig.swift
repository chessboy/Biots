//
//  GameConfig.swift
//  Biots
//
//  Created by Rob Silverman on 10/28/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation
import OctopusKit

enum ConfigParamType: Int {
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
	case weaponStaminaCost
	case armorEnergyCost
	
	case mutationRate
}

struct GameConfig: CustomStringConvertible {
	
	var name: String
	var simulationMode: SimulationMode
	var algaeTarget: Int
	var worldBlockCount: Int
	var worldRadius: CGFloat = .zero
	var minimumBiotCount: Int = 0
	var maximumBiotCount: Int = 0

	var worldObjects: [WorldObject] = []
	var genomes: [Genome] = []
	
	// environmental
	let dampeningWater: CGFloat = 0.2
	let generationThreshold = 200
	let clockRate = 60 // ticks per 1-way cycle
	
	var minGeneration = 0
	var maxGeneration = 0
	var useCrossover = false

	var configParams: [ConfigParamType: ConfigParam] = [
		// age
        .maximumAge: ConfigParam(start: 2280 * 2, end: 3600 * 2),
		
		// requirements
		.mateHealth: ConfigParam(start: 0.65, end: 0.8),
		.spawnHealth: ConfigParam(start: 0.55, end: 0.75),
		.maximumFoodEnergy: ConfigParam(start: 80, end: 120),
		.maximumHydration: ConfigParam(start: 80, end: 120),

		// costs
        .collisionDamage: ConfigParam(start: 0.1, end: 0.25) * 2,
        .perMovementStaminaRecovery: ConfigParam(start: 0.0015, end: 0.00125) * 0.5,
        .perMovementHydrationCost: ConfigParam(start: 0.0075, end: 0.01) * 0.25,
        .perMovementEnergyCost: ConfigParam(start: 0.0075, end: 0.0125) * 0.25,
        .speedBoostStaminaCost: ConfigParam(start: 0.0006, end: 0.0008) * 0.5,
        .weaponStaminaCost: ConfigParam(start: 0.0009, end: 0.0014) * 1.25,
        .armorEnergyCost: ConfigParam(start: 0.004, end: 0.008),
		
		// evolution
		.mutationRate: ConfigParam(start: 1, end: 0) // 1 = high ... 0 = low (not zero)
	]

	init(simulationMode: SimulationMode, worldBlockCount: Int = 10, algaeTarget: Int = 15000, minimumBiotCount: Int = 12, maximumBiotCount: Int = 24, useCrossover: Bool = true) {
		self.simulationMode = simulationMode
		self.worldBlockCount = worldBlockCount
		self.algaeTarget = 0

		name = "Untitled"

		if simulationMode != .debug {
			worldObjects = DataManager.shared.loadWorldObjects(type: .less)
			self.algaeTarget = algaeTarget
		}
		
		self.minimumBiotCount = minimumBiotCount
		self.maximumBiotCount = maximumBiotCount
		self.useCrossover = useCrossover

		setup()
	}
	
	var description: String {
		
		return "{name: \(name), gameMode: \(simulationMode.description), algaeTarget: \(algaeTarget), worldBlockCount: \(worldBlockCount), worldRadius: \(worldRadius.formattedNoDecimal), worldObjects: \(worldObjects.count), genomes: \(genomes.count), generations: \(minGeneration.abbrev)–\(maxGeneration.abbrev), biotCounts: \(minimumBiotCount)...\(maximumBiotCount), useCrossover: \(useCrossover)}"
	}

	init(saveState: SaveState) {
		name = saveState.name
		simulationMode = saveState.simulationMode
		algaeTarget = saveState.algaeTarget
		worldBlockCount = saveState.worldBlockCount
		self.worldObjects = saveState.worldObjects
		self.genomes = saveState.genomes.filter({ $0.generation > 0 }).shuffled()
		self.minimumBiotCount = saveState.minimumBiotCount
		self.maximumBiotCount = saveState.maximumBiotCount
		self.useCrossover = saveState.useCrossover
		
		setup()
	}
	
	mutating func setup() {
		worldRadius = Constants.Env.gridBlockSize * worldBlockCount.cgFloat
		minGeneration = genomes.map({$0.generation}).min() ?? 0
		maxGeneration = genomes.map({$0.generation}).max() ?? 0
		
		OctopusKit.logForSimInfo.add("new config: \(description)")
	}
	
	func valueForConfig(_ configParam: ConfigParamType, generation: Int) -> CGFloat {
		if let configParam = configParams[configParam] {
			return configParam.valueForGeneration(generation, generationThreshold: generationThreshold)
		}
		
		OctopusKit.logForSimWarnings.add("unknown configParam: \(configParam.rawValue)")
		return 0
	}
	
	func dumpGenomes() {
		print("\n[")
		var index = 0
		for genome in genomes {
			if let jsonData = try? genome.encodedToJSON() {
				if let jsonString = String(data: jsonData, encoding: .utf8) {
					let delim = index == genomes.count-1 ? "" : ","
					print("\(jsonString)\(delim)")
				}
			}
			index += 1
		}
		print("]\n")
	}
}
