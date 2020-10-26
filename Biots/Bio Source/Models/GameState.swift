//
//  GameState.swift
//  Biots
//
//  Created by Robert Silverman on 10/24/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation

struct GameState: Codable, CustomStringConvertible {
	var gameMode: GameMode
	var algaeTarget: Int
	var worldObjects: [WorldObject]
	var genomes: [Genome]
	
	var description: String {
		return "{gameMode: \(gameMode), algaeTarget: \(algaeTarget), worldObjects: \(worldObjects.count), genomes: \(genomes.count)}"
	}
}
