//
//  GameMode.swift
//  Biots
//
//  Created by Robert Silverman on 10/25/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation

enum GameMode: Int, Codable, CustomStringConvertible {
	case normal = 0
	case easy
	case random
	
	var description: String {
		switch self {
			case .easy: return "easy"
			case .random: return "random"
			case .normal: return "normal"
		}
	}
}
