//
//  DetectableObject.swift
//  SimStarter
//
//  Created by Robert Silverman on 4/24/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit

enum DetectableObject: Int, CaseIterable, CustomStringConvertible {
	
	case cell = 0
	case algae
	case wall
		
	var description: String {
		switch self {
		case .cell: return "cell"
		case .algae: return "algae"
		case .wall: return "wall"
		}
	}
		
	var skColor: SKColor {
		switch self {
		case .cell: return Constants.Colors.cell
		case .algae: return Constants.Colors.algae
		case .wall: return Constants.Colors.wall
		}
	}
}
