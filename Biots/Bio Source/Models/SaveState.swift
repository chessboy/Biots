//
//  SaveState.swift
//  Biots
//
//  Created by Robert Silverman on 10/24/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation

struct SaveState: Codable, CustomStringConvertible {
	var difficultyMode: DifficultyMode
	var algaeTarget: Int
	var placedObjects: [PlacedObject]
	var genomes: [Genome]
	
	var description: String {
		return "{difficultyMode: \(difficultyMode.description), algaeTarget: \(algaeTarget), placedObjects: \(placedObjects.count), genomes: \(genomes.count)}"
	}
}
