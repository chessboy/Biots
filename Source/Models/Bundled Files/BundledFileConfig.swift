//
//  BundleFileConfig.swift
//  Biots
//
//  Created by Robert Silverman on 10/25/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation

enum WorldObjectsBundleType {
	case less
	case more
	case sculpted

	var filename: String {
		switch self {
			case .less: return "world-objects-less"
			case .more: return "world-objects-more"
			case .sculpted: return "world-objects-sculpted"
		}
	}
}

struct BundledFileConfig: Codable {
	
	var simulationMode: SimulationMode
	var algaeTarget: Int
	var worldBlockCount: Int
	var worldObjectsFilename: String
	var genomeFilename: String
	var filename: String
	var minimumBiotCount: Int
	var maximumBiotCount: Int
}

