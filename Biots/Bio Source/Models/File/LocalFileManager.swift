//
//  LocalFileManager.swift
//  SwiftBots
//
//  Created by Robert Silverman on 10/17/18.
//  Copyright © 2018 fep. All rights reserved.
//

import Foundation
import OctopusKit

class LocalFileManager {
	
	static let shared = LocalFileManager()
	
	public func saveStateToFile(_ saveState: SaveState, filename: String, fileExtension: String = "json") {
				
		do {
			let encoder = JSONEncoder()
			let data = try encoder.encode(saveState)
			if let url = saveDataFile(filename, fileExtension: fileExtension, data: data) {
				OctopusKit.logForSimInfo.add("saved game state: \(url)")
			}
			
		} catch {
			OctopusKit.logForSimErrors.add("could not encode game state as \(filename).\(fileExtension): reason: \(error.localizedDescription)")
		}
	}
	
	private func createFileUrl(_ filename: String, create: Bool = false, fileExtension: String = "json") -> URL? {
		
		do {
			let documentDirectoryURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: create)
			return documentDirectoryURL.appendingPathComponent("\(filename).\(fileExtension)")
			
		} catch let error as NSError {
			OctopusKit.logForSimErrors.add("could not create file URL: \(filename).\(fileExtension): reason: \(error.localizedDescription)")
		}
		
		return nil
	}
	
	func saveDataFile(_ filename: String, fileExtension: String = "json", data: Data) -> URL? {
		
		if let fileUrl = createFileUrl(filename, create: true, fileExtension: fileExtension) {
			
			do {
				try data.write(to: fileUrl, options: .atomic)
				//OctopusKit.logForSim.add("LocalFileManager.saveDataFile success: \(fileUrl)")
				return fileUrl
				
			} catch let error as NSError {
				OctopusKit.logForSimErrors.add("could not save file: \(filename): reason: \(error.localizedDescription)")
			}
		}
		
		return nil
	}
	
	func loadDataFile<T: Decodable>(_ filename: String, fileExtension: String = "json", treatAsWarning: Bool = false) -> T? {
		
		if let fileUrl = createFileUrl(filename, fileExtension: fileExtension) {
			
			do {
				let data = try Data(contentsOf: fileUrl, options: .alwaysMapped)
				OctopusKit.logForSimInfo.add("data file loaded successfully: \(fileUrl)")

				do {
					let decoder = JSONDecoder()
					return try decoder.decode(T.self, from: data)
				} catch {
					OctopusKit.logForSimErrors.add("could not parse \(filename) as \(T.self):\n\(error)")
				}
				
			} catch let error as NSError {
				let errorDescription = "could not load contents of file \(filename): reason: \(error.localizedDescription)"
				if treatAsWarning {
					OctopusKit.logForSimWarnings.add(errorDescription)
				}
				else {
					OctopusKit.logForSimErrors.add(errorDescription)
				}
			}
		}
		
		return nil
	}
	
	func deleteFile(_ fileUrl: URL) {
		
		do {
			try FileManager.default.removeItem(at: fileUrl)
			OctopusKit.logForSimInfo.add("deleteFile: success: \(fileUrl)")
			
		} catch let error as NSError {
			
			if error.code != 4 {
				// ignore file not found
				OctopusKit.logForSimErrors.add("deleteFile: error deleting file: \(fileUrl): error: \(error.localizedDescription), code: \(error.code)")
				
			} else {
				OctopusKit.logForSimInfo.add("deleteFile: file not found: \(fileUrl)")
			}
		}
	}
	
	func deleteFile(_ filename: String, fileExtension: String = "json") {
		
		if let fileUrl = createFileUrl(filename, fileExtension: fileExtension) {
			deleteFile(fileUrl)
		}
	}
}
