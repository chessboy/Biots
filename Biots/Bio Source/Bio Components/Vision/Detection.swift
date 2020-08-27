//
//  Detection.swift
//  BioGenesis
//
//  Created by Robert Silverman on 4/17/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation

struct Detection: CustomStringConvertible {
	
	static let detectableCategories = DetectableObject.allCases.count
	
	var id: String?
	var angleIndex: Int
	var detectableObject: DetectableObject
	var proximity: CGFloat
	
		
	var description: String {
		let idDescr = id == nil ? "" : ", id: \(id!)"
		return "{\(angleIndex): detectableObject: \(detectableObject), proximity: \(proximity.formattedTo2Places)\(idDescr)}"
	}
	
	/*
	case female = 0
	case femaleMating
	case male
	case maleMating
	case algae
	case wall
	*/
	
	static func detectionsToInputs(_ detections: [Detection], senses: Senses, training: Bool = false) -> [Float] {

		var inputs = Array(repeating: Float.zero, count: Constants.EyeVector.eyeAngles.count * detectableCategories)
		
		// detections
		detections.forEach({
			let offset: Int = $0.detectableObject.rawValue
			let index = ($0.angleIndex * detectableCategories) + offset
			inputs[index] = Float($0.proximity)
		})
		 
		if training {
			for angleIndex in 0..<Constants.EyeVector.eyeAngles.count {
				let femaleIndex = (angleIndex * detectableCategories)
				let femaleMatingIndex = (angleIndex * detectableCategories) + 1
				let maleIndex = (angleIndex * detectableCategories) + 2
				let maleMatingIndex = (angleIndex * detectableCategories) + 3
				
				inputs[femaleIndex] = max(inputs[femaleIndex], inputs[femaleMatingIndex])
				inputs[femaleMatingIndex] = max(inputs[femaleIndex], inputs[femaleMatingIndex])
				inputs[maleIndex] = max(inputs[maleIndex], inputs[maleMatingIndex])
				inputs[maleMatingIndex] = max(inputs[maleIndex], inputs[maleMatingIndex])
				
//				if inputs[femaleIndex] > 0 || inputs[maleIndex] > 0 {
//					print(inputs)
//				}
			}
		}
		
		// senses
		inputs.append(contentsOf: senses.toArray)
		
//		if detections.count > 0 {
//			print("\(detections)\n\(inputs)\n")
//		}
		
		return inputs
	}
}

