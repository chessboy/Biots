//
//  SimulationMode.swift
//  Biots
//
//  Created by Robert Silverman on 10/25/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation

enum SimulationMode: Int, Codable, CustomStringConvertible {
	case normal = 0
	case random
	case debug
	case predatorPrey
	case randomPredatorPrey
	
	var humanReadableDescription: String {
		switch self {
			case .random: return "random"
			case .normal: return "normal"
			case .debug: return "debug"
			case .predatorPrey: return "pred/prey"
			case .randomPredatorPrey: return "random pred/prey"
		}
	}
	
	var isRandom: Bool {
		return self == .random || self == .randomPredatorPrey
	}
	
	var description: String {
		return "{mode: \(humanReadableDescription), isRandom: \(isRandom), dispenseDelay: \(dispenseDelay), dispenseInterval: \(dispenseInterval)}"
	}
	
	var dispenseDelay: Int {
		switch self {
			case .debug: return 0
			default: return 250
		}
	}
	
	var dispenseInterval: Int {
		switch self {
			case .random, .randomPredatorPrey: return 10
			case .normal, .predatorPrey: return 50
			case .debug: return 1
		}
	}
}
