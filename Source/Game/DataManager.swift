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
	static let currentFileVersion = 8
	static let shared = DataManager()
	
	static let keyInstalledFileVersion = "installedFileVersion"
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

		let installedVersion = defaults.integer(forKey: DataManager.keyInstalledFileVersion)

		OctopusKit.logForSimInfo.add("currentVersion: \(DataManager.currentFileVersion), installedVersion: \(installedVersion)")
		if installedVersion < DataManager.currentFileVersion {
			
			if let bundledFileConfigs: [BundledFileConfig] = loadJsonFromFile(DataManager.bundledFileConfigFilename) {
				
				for config in bundledFileConfigs {
					if let worldObjects: [WorldObject] = loadJsonFromFile(config.worldObjectsFilename), let genomes: [Genome] = loadJsonFromFile(config.genomeFilename) {
						let saveState = SaveState(name: config.filename, simulationMode: config.simulationMode, algaeTarget: config.algaeTarget, worldBlockCount: config.worldBlockCount, worldObjects: worldObjects, genomes: genomes, minimumBiotCount: config.minimumBiotCount, maximumBiotCount: config.maximumBiotCount, omnivoreToHerbivoreRatio: 0.5, useCrossover: false)
						LocalFileManager.shared.saveStateToFile(saveState, filename: config.filename)
					}
				}
				
				defaults.set(DataManager.currentFileVersion, forKey: DataManager.keyInstalledFileVersion)
			}
		}
	}
}
