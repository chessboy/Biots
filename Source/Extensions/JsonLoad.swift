//
//  JsonLoad.swift
//  Biots
//
//  Created by Robert Silverman on 4/16/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation
import OctopusKit

// load data as `codeable` objects from a bundled file
func loadJsonFromFile<T: Decodable>(_ filename: String, fileExtension: String = "json") -> T? {
	let data: Data
	
	guard let file = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
		OctopusKit.logForSimErrors.add("Couldn't find \(filename) in main bundle.")
		return nil
	}
	
	do {
		data = try Data(contentsOf: file)
	} catch {
		OctopusKit.logForSimErrors.add("Couldn't load \(filename) from main bundle:\n\(error)")
		return nil
	}
	
	do {
		let decoder = JSONDecoder()
		return try decoder.decode(T.self, from: data)
	} catch {
		OctopusKit.logForSimErrors.add("Couldn't parse \(filename) as \(T.self):\n\(error)")
		return nil
	}
}
