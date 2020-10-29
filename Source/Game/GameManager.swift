//
//  GameManager.swift
//  Biots
//
//  Created by Rob Silverman on 10/28/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation
class GameManager {
	
	static let shared = GameManager()
	var gameConfig = GameConfig(gameMode: .random)
}
