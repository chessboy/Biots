//
//  GameConfig.swift
//  Biots
//
//  Created by Rob Silverman on 10/28/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation

struct GameConfig {
	
	var gameMode: GameMode
	var algaeTarget: Int
	var worldBlockCount: Int
	var worldRadius: CGFloat = .zero
	var worldObjects: [WorldObject] = []
	var genomes: [Genome] = []
	
	var minimumBiotCount: Int = 0
	var maximumBiotCount: Int = 0
	
	init(gameMode: GameMode) {
		self.gameMode = gameMode
		algaeTarget = 12000
		worldBlockCount = 10
		worldObjects = DataManager.shared.loadWorldObjects(type: .less)
		
		minimumBiotCount = 12
		maximumBiotCount = 24

		setup()
	}
	
	init(saveState: SaveState) {
		gameMode = saveState.gameMode
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
	}
}
