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
			case .normal: return ""
			case .debug: return "debug"
		}
	}
	
	var description: String {
		return "{mode: \(humanReadableDescription), dispenseDelay: \(dispenseDelay), dispenseInterval: \(dispenseInterval)}"
	}
	
	var dispenseDelay: Int {
		switch self {
			case .random: return 20
			case .normal: return 250
			case .debug: return 0
		}
	}
	
	var dispenseInterval: Int {
		switch self {
			case .random: return 10
			case .normal: return 50
			case .debug: return 0
		}
	}
}
