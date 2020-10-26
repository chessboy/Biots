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

	var saveState: SaveState?
	
	init() {
		checkLocalDocuments()
		
		if let saveState: SaveState = LocalFileManager.shared.loadDataFile(Constants.Env.saveSavedStateFilename, treatAsWarning: true) {
			self.saveState = saveState
			OctopusKit.logForSimInfo.add("loaded save state: \(saveState.description)")
		}
		else if let saveState: SaveState = LocalFileManager.shared.loadDataFile(Constants.Env.firstRunSavedStateFilename) {
			self.saveState = saveState
			OctopusKit.logForSimInfo.add("loaded save state: \(saveState.description)")
		} else {
			OctopusKit.logForSimErrors.add("could not load a save state")
		}
	}
	
	func checkLocalDocuments() {
		let defaults = UserDefaults.standard

		if !defaults.bool(forKey: DataManager.keyCreatedLocalDocuments) {
			
			if let bundledFileConfigs: [BundledFileConfig] = loadJsonFromFile(DataManager.bundledFileConfigFilename) {
				
				for config in bundledFileConfigs {
					if let worldObjects: [WorldObject] = loadJsonFromFile(config.worldObjectsFilename), let genomes: [Genome] = loadJsonFromFile(config.genomeFilename) {
						let saveState = SaveState(difficultyMode: config.difficultyMode, algaeTarget: config.algaeTarget, worldObjects: worldObjects, genomes: genomes)
						LocalFileManager.shared.saveStateToFile(saveState: saveState, filename: config.filename)
					}
				}
				
				defaults.set(true, forKey: DataManager.keyCreatedLocalDocuments)
			}
		}
	}
}
