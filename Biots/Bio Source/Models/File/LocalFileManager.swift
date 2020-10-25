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
	
	public func saveStateToFile(saveState: SaveState, filename: String, fileExtension: String = "json") {
				
		do {
			let encoder = JSONEncoder()
			let data = try encoder.encode(saveState)
			if let url = saveDataFile(filename, fileExtension: fileExtension, data: data) {
				OctopusKit.logForSim.add("Saved SaveState: \(url)")
			}
			
		} catch {
			OctopusKit.logForSimErrors.add("Couldn't encode SaveState as \(filename).\(fileExtension):\n\(error)")
		}
	}
	
	private func createFileUrl(_ filename: String, create: Bool = false, fileExtension: String = "json") -> URL? {
		
		do {
			let documentDirectoryURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: create)
			return documentDirectoryURL.appendingPathComponent("\(filename).\(fileExtension)")
			
		} catch let error as NSError {
			OctopusKit.logForSimErrors.add("LocalFileManager: could not create file URL: \(filename).\(fileExtension): error: \(error.localizedDescription)")
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
				OctopusKit.logForSimErrors.add("LocalFileManager: could not save file: \(filename): error: \(error.localizedDescription)")
			}
		}
		
		return nil
	}
	
	func loadDataFile<T: Decodable>(_ filename: String, fileExtension: String = "json") -> T? {
		
		if let fileUrl = createFileUrl(filename, fileExtension: fileExtension) {
			
			do {
				let data = try Data(contentsOf: fileUrl, options: .alwaysMapped)
				OctopusKit.logForSim.add("LocalFileManager: loadDataFile success: \(fileUrl)")

				do {
					let decoder = JSONDecoder()
					return try decoder.decode(T.self, from: data)
				} catch {
					OctopusKit.logForSimErrors.add("Couldn't parse \(filename) as \(T.self):\n\(error)")
				}
				
			} catch let error as NSError {
				OctopusKit.logForSimErrors.add("LocalFileManager: error loading contents of file \(filename): error: \(error.localizedDescription)")
			}
		}
		
		return nil
	}
	
	func deleteFile(_ fileUrl: URL) {
		
		do {
			try FileManager.default.removeItem(at: fileUrl)
			OctopusKit.logForSim.add("LocalFileManager: deleteFile: success: \(fileUrl)")
			
		} catch let error as NSError {
			
			if error.code != 4 {
				// ignore file not found
				OctopusKit.logForSimErrors.add("LocalFileManager: deleteFile: error deleting file: \(fileUrl): error: \(error.localizedDescription), code: \(error.code)")
				
			} else {
				OctopusKit.logForSim.add("LocalFileManager: deleteFile: file not found: \(fileUrl)")
			}
		}
	}
	
	func deleteFile(_ filename: String, fileExtension: String = "json") {
		
		if let fileUrl = createFileUrl(filename, fileExtension: fileExtension) {
			deleteFile(fileUrl)
		}
	}
}
