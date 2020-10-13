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
		let filename = Constants.Env.zooFilename
		genomes = loadJsonFromFile(filename)
		print("GenomeFactory: loaded \(genomes.count) genomes from \(filename)")

		if let mixinFilename = Constants.Env.mixinZooFilename {
			let mixinGenomes: [Genome] = loadJsonFromFile(mixinFilename)
			print("GenomeFactory: loaded \(genomes.count) genomes from \(mixinFilename)")
			genomes.append(contentsOf: mixinGenomes)
		}
		
		//genomes = genomes.filter({ $0.generation >= 1 })
		genomes = genomes.shuffled()
		//genomes.forEach { print($0.description) }
	}
	
	func genome(named: String) -> Genome? {
		return genomes.filter({ $0.id == named }).first
	}
	
	var newRandomGenome: Genome {
		let inputCount = Constants.Vision.eyeAngles.count * Constants.Vision.colorDepth + Senses.newInputCount
		let outputCount = Inference.outputCount
		let hiddenCounts = Constants.NeuralNet.newGenomeHiddenCounts

		return Genome(inputCount: inputCount, hiddenCounts: hiddenCounts, outputCount: outputCount)
	}
}





