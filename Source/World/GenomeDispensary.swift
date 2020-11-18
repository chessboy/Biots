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
}

struct GenomeDispensary {
	
	var dispensaryType: DispensaryType
	var minWorldCount: Int = 0
	var maxWorldCount: Int = 0
	var fileGenomes: [Genome] = []
	var fileDispenseIndex = 0
	var unbornGenomes: [Genome] = []

	init(dispensaryType: DispensaryType, gameConfig: GameConfig) {
		self.dispensaryType = dispensaryType
		
		switch dispensaryType {
			case .omnivore: fileGenomes = gameConfig.omnivoreGenomes
			case .herbivore: fileGenomes = gameConfig.herbivoreGenomes
			default: fileGenomes = gameConfig.genomes
		}
				
		let minGeneral = gameConfig.minimumBiotCount
		let maxGeneral = gameConfig.maximumBiotCount
		let omnivoreRatio = Constants.Env.omnivoreToHerbivoreRatio
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
		
		if unbornGenomes.count > 0 {
			if let genome = unbornGenomes.sorted(by: { (genome1, genome2) -> Bool in
				genome1.generation > genome2.generation
			}).first {
				unbornGenomes = unbornGenomes.filter({ $0.id != genome.id })
				return genome
			}
		}
		
		guard fileGenomes.count > 0 else { return nil }
		
		let genomeIndex = fileDispenseIndex % fileGenomes.count
		var genomeToDispense = fileGenomes[genomeIndex]
		genomeToDispense.id = "\(genomeToDispense.id)-\(fileDispenseIndex)"
		fileDispenseIndex += 1
		return genomeToDispense
	}
	
	func shouldCacheGenome(currentCount: Int) -> Bool {
		return currentCount >= maxWorldCount
	}

	mutating func cacheGenome(_ genome: Genome) {
		if unbornGenomes.count == Constants.Env.unbornGenomeCacheCount {
			unbornGenomes.remove(at: 0)
		}
		unbornGenomes.append(genome)
		OctopusKit.logForSimInfo.add("\(dispensaryType.rawValue) dispensary added 1 unborn genome: \(genome.description), cache size: \(unbornGenomes.count)")
	}

}
