//
//  GenomeFactory.swift
//  SwiftBots
//
//  Created by Robert Silverman on 10/3/18.
//  Copyright © 2018 fep. All rights reserved.
//

import Foundation
import SpriteKit

class GenomeFactory {
	
	static let shared = GenomeFactory()
	var population: Population?
	
	init() {
		let filename = Constants.Env.filename
		
		if let filePopulation: Population = loadJsonFromFile(filename) {
			population = filePopulation
			print("GenomeFactory: loaded \(filePopulation) from \(filename)")
		}
		
	}
	
	func genome(named: String) -> Genome? {
		guard let population = population else { return nil }
		
		return population.genomes.filter({ $0.id == named }).first
	}
	
	var newRandomGenome: Genome {
		let inputCount = Constants.Vision.eyeAngles.count * Constants.Vision.colorDepth + Senses.newInputCount
		let outputCount = Inference.outputCount
		let hiddenCount = 24

		let genome = Genome(inputCount: inputCount, hiddenCount: hiddenCount, outputCount: outputCount)
		//print(genome.description)
		return genome
	}
}





