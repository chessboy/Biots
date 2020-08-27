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
	var genomes: [Genome] = []
	
	init() {
		let filename = Constants.Environment.filename
		genomes = loadJsonFromFile(filename)
		genomes = genomes.filter({ $0.generation > 0 })
		print("GenomeFactory: loaded \(genomes.count) genomes from \(filename):")
		//genomes.forEach { print($0.description) }
	}
	
	func genome(named: String) -> Genome? {
		return genomes.filter({ $0.id == named }).first
	}
	
	var newRandomGenome: Genome {
		let detectableCategories = Detection.detectableCategories
		let eyeCount = Constants.EyeVector.eyeAngles.count
		let additionalInputs = Senses.senseInputCount
		let inputCount = detectableCategories * eyeCount + additionalInputs
		let outputCount = Inference.outputCount
		let hiddenCount = 16

		let genome = Genome(inputCount: inputCount, hiddenCount: hiddenCount, outputCount: outputCount)
		//print(genome.description)
		return genome
	}
}





