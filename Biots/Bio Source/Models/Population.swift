//
//  Population.swift
//  Biots
//
//  Created by Robert Silverman on 9/21/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation

struct Population: Codable, CustomStringConvertible {
	var minGen: Int
	var maxGen: Int
	var algaeTarget: Int
	var genomes: [Genome]
	
	var description: String {
		return "gen: \(minGen)–\(maxGen), alg: \(algaeTarget.formatted), count: \(genomes.count)"
	}
	
	init(genomes: [Genome], algaeTarget: Int) {
		self.genomes = genomes
		self.algaeTarget = algaeTarget
		
		minGen = genomes.map({$0.generation}).min() ?? 0
		maxGen = genomes.map({$0.generation}).max() ?? 0
	}
}
