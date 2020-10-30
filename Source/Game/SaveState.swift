//
//  SaveState.swift
//  Biots
//
//  Created by Robert Silverman on 10/24/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation

struct SaveState: Codable, CustomStringConvertible {
	var name: String
	var gameMode: GameMode
	var algaeTarget: Int
	var worldBlockCount: Int
    
	var worldObjects: [WorldObject]
	var genomes: [Genome]
	
	var minimumBiotCount: Int
	var maximumBiotCount: Int
	
	var description: String {
		return "{name: \(name), gameMode: \(gameMode), algaeTarget: \(algaeTarget), worldBlockCount: \(worldBlockCount), worldObjects: \(worldObjects.count), genomes: \(genomes.count), minimumBiotCount: \(minimumBiotCount), maximumBiotCount: \(maximumBiotCount)}"
	}
}
