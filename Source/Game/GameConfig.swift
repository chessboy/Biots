//
//  GameConfig.swift
//  Biots
//
//  Created by Rob Silverman on 10/28/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation
import OctopusKit

struct ConfigParam: CustomStringConvertible {
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
	case armorEnergyCost
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
	let biotCarcasesArePowerFood = true
	let generationThreshold = 200
	let clockRate = 60 // ticks per 1-way cycle

	var configParams: [ConfigParamType : ConfigParam] = [
		// age
		.maximumAge : ConfigParam(start: 2280, end: 3300),
		
		// requirements
		.mateHealth : ConfigParam(start: 0.65, end: 0.8),
		.spawnHealth : ConfigParam(start: 0.55, end: 0.75),
		.maximumFoodEnergy : ConfigParam(start: 80, end: 120),
		.maximumHydration : ConfigParam(start: 80, end: 120),

		// costs
		.collisionDamage : ConfigParam(start: 0.10, end: 0.25),
		.perMovementStaminaRecovery : ConfigParam(start: 0.0015, end: 0.00125),
		.perMovementHydrationCost : ConfigParam(start: 0.0075, end: 0.01),
		.perMovementEnergyCost : ConfigParam(start: 0.0075, end: 0.0125),
		.speedBoostStaminaCost : ConfigParam(start: 0.0006, end: 0.0008),
		.armorEnergyCost : ConfigParam(start: 0.04, end: 0.06)
	]

	init(simulationMode: SimulationMode) {
		self.simulationMode = simulationMode
		name = "Random"
		worldBlockCount = 13
		algaeTarget = 0

		if simulationMode != .debug {
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

		return "{name: \(name), gameMode: \(simulationMode.description), algaeTarget: \(algaeTarget), worldBlockCount: \(worldBlockCount), worldRadius: \(worldRadius.formattedNoDecimal), worldObjects: \(worldObjects.count), genomes: \(genomes.count), generations: \(minGen.abbrev)–\(maxGen.abbrev), biotCounts: \(minimumBiotCount)...\(maximumBiotCount)}"
	}

	
	init(saveState: SaveState) {
		name = saveState.name
		simulationMode = saveState.simulationMode
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
