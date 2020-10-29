//
//  DataManager.swift
//  Biots
//
//  Created by Robert Silverman on 10/24/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation
import OctopusKit

class DataManager {
	static let shared = DataManager()
	
	static let keyCreatedLocalDocuments = "createdLocalDocuments"
	static let bundledFileConfigFilename = "bundled-file-configs"
	
	init() {
		checkLocalDocuments()
	}
	
	func loadWorldObjects(type: WorldObjectsBundleType) -> [WorldObject] {
		if let worldObjects: [WorldObject] = loadJsonFromFile(type.filename) {
			return worldObjects
		}
		
		return []
	}
	
	func checkLocalDocuments() {
		let defaults = UserDefaults.standard

		if !defaults.bool(forKey: DataManager.keyCreatedLocalDocuments) {
			
			if let bundledFileConfigs: [BundledFileConfig] = loadJsonFromFile(DataManager.bundledFileConfigFilename) {
				
				for config in bundledFileConfigs {
					if let worldObjects: [WorldObject] = loadJsonFromFile(config.worldObjectsFilename), let genomes: [Genome] = loadJsonFromFile(config.genomeFilename) {
						let saveState = SaveState(gameMode: config.gameMode, algaeTarget: config.algaeTarget, worldBlockCount: config.worldBlockCount, worldObjects: worldObjects, genomes: genomes, minimumBiotCount: config.minimumBiotCount, maximumBiotCount: config.maximumBiotCount)
						LocalFileManager.shared.saveStateToFile(saveState, filename: config.filename)
					}
				}
				
				defaults.set(true, forKey: DataManager.keyCreatedLocalDocuments)
			}
		}
	}
}
