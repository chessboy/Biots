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
	
	var humanReadableDescription: String {
		switch self {
			case .random: return "random"
			case .normal: return "normal"
			case .debug: return "debug"
		}
	}
	
	var isRandom: Bool {
		return self == .random
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
        case .random: return 10
        case .normal: return 50
        case .debug: return 1
        }
    }
}
