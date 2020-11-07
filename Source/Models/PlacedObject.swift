//
//  WorldObject.swift
//  Biots
//
//  Created by Robert Silverman on 10/10/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation
import SpriteKit

enum PlaceableType: Int, Codable {
	case zapper = 0
	case water
	case mud
}

struct WorldObject: Codable {
	var placeableType: PlaceableType
	var angle: Float
	var percentFromCenter: Float
	var percentRadius: Float
}

extension SKNode {
	func createWorldObject(placeableType: PlaceableType, radius: CGFloat) -> WorldObject {
		let percentFromCenter = position.distance(to: .zero) / GameManager.shared.gameConfig.worldRadius
		let percentRadius = radius / GameManager.shared.gameConfig.worldRadius
		return WorldObject(placeableType: placeableType, angle: position.angle.float, percentFromCenter: percentFromCenter.float, percentRadius: percentRadius.float)
	}
}
