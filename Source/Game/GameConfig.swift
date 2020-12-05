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
	case omnivoreNutrientRatio
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
	var omnivoreToHerbivoreRatio: CGFloat = 0.5
	var algaeTarget: Int
	var worldBlockCount: Int
	var worldRadius: CGFloat = .zero
	var minimumBiotCount: Int = 0
	var maximumBiotCount: Int = 0

	var worldObjects: [WorldObject] = []
	var genomes: [Genome] = []
	var omnivoreGenomes: [Genome] = []
	var herbivoreGenomes: [Genome] = []
	
	// environmental
	let dampeningWater: CGFloat = 0.2
	let generationThreshold = 200
	let clockRate = 60 // ticks per 1-way cycle
	
	var minGeneration = 0
	var maxGeneration = 0
	var useCrossover = false

	var configParams: [ConfigParamType: ConfigParam] = [
		// age
		.maximumAge: ConfigParam(start: 2280, end: 3300),
		
		// requirements
		.mateHealth: ConfigParam(start: 0.65, end: 0.8),
		.spawnHealth: ConfigParam(start: 0.55, end: 0.75),
		.maximumFoodEnergy: ConfigParam(start: 80, end: 120),
		.maximumHydration: ConfigParam(start: 80, end: 120),

		// costs
		.omnivoreNutrientRatio: ConfigParam(start: 1, end: 1),
		.collisionDamage: ConfigParam(start: 0.1, end: 0.25),
		.perMovementStaminaRecovery: ConfigParam(start: 0.0015, end: 0.00125),
		.perMovementHydrationCost: ConfigParam(start: 0.0075, end: 0.01),
		.perMovementEnergyCost: ConfigParam(start: 0.0075, end: 0.0125),
		.speedBoostStaminaCost: ConfigParam(start: 0.0006, end: 0.0008),
		.weaponStaminaCost: ConfigParam(start: 0.0008, end: 0.0016),
		.armorEnergyCost: ConfigParam(start: 0.04, end: 0.06),
		
		// evolution
		.mutationRate: ConfigParam(start: 1, end: 0) // 1 = high ... 0 = low (not zero)
	]

	init(simulationMode: SimulationMode, worldBlockCount: Int = 10, algaeTarget: Int = 15000, minimumBiotCount: Int = 12, maximumBiotCount: Int = 24, omnivoreToHerbivoreRatio: CGFloat = 0.5, useCrossover: Bool = false) {
		self.simulationMode = simulationMode
		self.omnivoreToHerbivoreRatio = omnivoreToHerbivoreRatio
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
		
		return "{name: \(name), gameMode: \(simulationMode.description), algaeTarget: \(algaeTarget), worldBlockCount: \(worldBlockCount), worldRadius: \(worldRadius.formattedNoDecimal), worldObjects: \(worldObjects.count), genomes: \(genomes.count), generations: \(minGeneration.abbrev)–\(maxGeneration.abbrev), biotCounts: \(minimumBiotCount)...\(maximumBiotCount), omnivoreToHerbivoreRatio: \(omnivoreToHerbivoreRatio.formattedTo2Places), useCrossover: \(useCrossover)}"
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

		if simulationMode == .predatorPrey || simulationMode == .randomPredatorPrey {
			omnivoreGenomes = genomes.filter { $0.isOmnivore }
			herbivoreGenomes = genomes.filter { $0.isHerbivore }
			omnivoreToHerbivoreRatio = CGFloat(saveState.omnivoreToHerbivoreRatio)
		}
		
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
