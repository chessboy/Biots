//
//  BundleFileConfig.swift
//  Biots
//
//  Created by Robert Silverman on 10/25/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation

struct BundledFileConfig: Codable {
	
	var difficultyMode: DifficultyMode
	var algaeTarget: Int
	var placedObjectsFilename: String
	var genomeFilename: String
	var filename: String
}

