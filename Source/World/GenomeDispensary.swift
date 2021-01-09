//
//  GenomeDispensary.swift
//  Biots
//
//  Created by Rob Silverman on 11/18/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation
import OctopusKit

enum DispensaryType: String {
	case general
	case omnivore
	case herbivore
	
	var species: Species {
		switch self {
			case .herbivore: return .herbivore
			case .omnivore: return .omnivore
			default: return Bool.random() ? .herbivore : .omnivore
		}
	}
}

struct LivingGenome: CustomStringConvertible {
	var genome: Genome
	var averageHealth: Float
	
	var description: String {
		return "{genome: \(genome.description), averageHealth: \(averageHealth.formattedToPercent)}"
	}
}

struct GenomeDispensary {
	
	var dispensaryType: DispensaryType
	var minWorldCount: Int = 0
	var maxWorldCount: Int = 0
	var fileGenomes: [Genome] = []
	var fileDispenseIndex = 0
	var genomeCache: [LivingGenome] = []
	var isRandomMode: Bool = false

	init(dispensaryType: DispensaryType, gameConfig: GameConfig) {
		self.dispensaryType = dispensaryType
		isRandomMode = gameConfig.simulationMode.isRandom
		
		switch dispensaryType {
			case .omnivore: fileGenomes = gameConfig.omnivoreGenomes
			case .herbivore: fileGenomes = gameConfig.herbivoreGenomes
			default: fileGenomes = gameConfig.genomes
		}
				
		let minGeneral = gameConfig.minimumBiotCount
		let maxGeneral = gameConfig.maximumBiotCount
		let omnivoreRatio = gameConfig.omnivoreToHerbivoreRatio
		let herbivoreRatio = 1 - omnivoreRatio
		let minOmnivore = Int(gameConfig.minimumBiotCount.cgFloat * omnivoreRatio)
		let minHerbivore = Int(gameConfig.minimumBiotCount.cgFloat * herbivoreRatio)
		let maxOmnivore = Int(gameConfig.maximumBiotCount.cgFloat * omnivoreRatio)
		let maxHerbivore = Int(gameConfig.maximumBiotCount.cgFloat * herbivoreRatio)

		self.minWorldCount = dispensaryType == .omnivore ? minOmnivore : dispensaryType == .herbivore ? minHerbivore : minGeneral
		self.maxWorldCount = dispensaryType == .omnivore ? maxOmnivore : dispensaryType == .herbivore ? maxHerbivore : maxGeneral
		
		OctopusKit.logForSimInfo.add("GenomeDispensary created: \(dispensaryType.rawValue). fileGenomes = \(fileGenomes.count), worldCounts: \(minWorldCount)-\(maxWorldCount)")
	}
			
	mutating func nextGenome(currentCount: Int) -> Genome? {
		
		guard currentCount < minWorldCount else {
			return nil
		}
		
		if genomeCache.count > 0 {
			if let livingGenome = genomeCache.sorted(by: { (livingGenome1, livingGenome2) -> Bool in
				livingGenome1.averageHealth > livingGenome2.averageHealth
			}).first {
				genomeCache = genomeCache.filter({ $0.genome.id != livingGenome.genome.id })
				OctopusKit.logForSimInfo.add("\(dispensaryType.rawValue) dispensary decanted unborn genome: \(livingGenome.genome.description), cache size: \(genomeCache.count)")
				return livingGenome.genome
			}
		}
		else if fileGenomes.count > 0 {
			let genomeIndex = fileDispenseIndex % fileGenomes.count
			var genomeToDispense = fileGenomes[genomeIndex]
			genomeToDispense.id = "\(genomeToDispense.id)-\(fileDispenseIndex)"
			fileDispenseIndex += 1
			OctopusKit.logForSimInfo.add("\(dispensaryType.rawValue) dispensary decanted file genome: \(genomeToDispense.description)")
			return genomeToDispense
		}
		else if isRandomMode {
			let genome = Genome.newRandomGenome(species: .omnivore /*dispensaryType.species*/)
			OctopusKit.logForSimInfo.add("\(dispensaryType.rawValue) dispensary created random \(dispensaryType.species.description) genome: \(genome.description)")
			return genome
		}

		return nil
	}
	
	func shouldCacheGenome(currentCount: Int) -> Bool {
		return currentCount >= maxWorldCount
	}

	mutating func cacheGenome(_ genome: Genome, averageHealth: Float) {
		if genomeCache.count == Constants.Env.unbornGenomeCacheCount {
			genomeCache.remove(at: 0)
		}
		genomeCache.append(LivingGenome(genome: genome, averageHealth: averageHealth))
		OctopusKit.logForSimInfo.add("\(dispensaryType.rawValue) dispensary added 1 unborn genome: \(genome.description), cache size: \(genomeCache.count)")
	}

	mutating func mostFitGenome(removeFromCache: Bool) -> Genome? {
		guard genomeCache.count > 0 else {
			return nil
		}
		
		if let mostFit = genomeCache.sorted(by: { (livingGenome1, livingGenome2) -> Bool in
			livingGenome1.averageHealth > livingGenome2.averageHealth
		}).first?.genome {
		
			if removeFromCache {
				removeGenomeFromCache(mostFit)
			}
			OctopusKit.logForSimInfo.add("\(dispensaryType.rawValue) dispensary decanted most fit unborn genome: \(mostFit.description), cache size: \(genomeCache.count)")
			return mostFit
		}
		
		return nil
	}
	
	mutating func removeGenomeFromCache(_ genome: Genome) {
		genomeCache = genomeCache.filter({ $0.genome.id != genome.id })
	}
}
