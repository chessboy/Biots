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
	
	var saveState: SaveState?
	
	init() {
		checkLocalDocuments()
		
		if let saveState: SaveState = LocalFileManager.shared.loadDataFile(Constants.Env.firstRunSavedStateFilename) {
			self.saveState = saveState
			OctopusKit.logForSim.add("loaded save state: \(saveState.description)")
		} else {
			OctopusKit.logForSimErrors.add("could not load save state named: \(Constants.Env.firstRunSavedStateFilename)")
		}
	}
	
	func checkLocalDocuments() {
		let defaults = UserDefaults.standard
		
		if !defaults.bool(forKey: DataManager.keyCreatedLocalDocuments) {
			let filename = "Evolved"
			let algaeTarget = 10000
			if let placedObjects: [PlacedObject] = loadJsonFromFile("placedObjects-more"), let genomes: [Genome] = loadJsonFromFile("genomes-1740") {
				let saveState = SaveState(difficultyMode: .normal, algaeTarget: algaeTarget, placedObjects: placedObjects, genomes: genomes)
				LocalFileManager.shared.saveStateToFile(saveState: saveState, filename: filename)
				defaults.set(true, forKey: DataManager.keyCreatedLocalDocuments)
			}
		}
	}
	
	func createSavedStateFiled() {
//		let filename = Constants.Env.placedObjectsFilename
//		let placedObjects: [PlacedObject] = loadJsonFromFile(filename)

	}
	
//	func copyFileToDocumentsFolder(filename: String, fileExtension: String = "json") {
//
//		guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//			OctopusKit.logForSimErrors.add("could obtain documents URL")
//			return
//		}
//		let destinationURL = documentsURL.appendingPathComponent(filename).appendingPathExtension(fileExtension)
//
//		guard let sourceURL = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
//			OctopusKit.logForSimErrors.add("source file not found: \(filename).\(fileExtension)")
//			return
//		}
//
//		let fileManager = FileManager.default
//		do {
//			try fileManager.copyItem(at: sourceURL, to: destinationURL)
//			OctopusKit.logForSim.add("source file copied to: \(destinationURL)")
//		} catch {
//			OctopusKit.logForSimErrors.add("could not copy file: \(filename).\(fileExtension)")
//		}
//	}

}
