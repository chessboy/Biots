//
//  NodePlacement.swift
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
}

struct PlacedObject: Codable {
	var placeableType: PlaceableType
	var angle: Float
	var percentFromCenter: Float
	var percentRadius: Float
}

extension SKNode {
	func createPlacedObject(placeableType: PlaceableType, radius: CGFloat) -> PlacedObject {
		let percentFromCenter = position.distance(to: .zero) / Constants.Env.worldRadius
		let percentRadius = radius / Constants.Env.worldRadius
		return PlacedObject(placeableType: placeableType, angle: position.angle.float, percentFromCenter: percentFromCenter.float, percentRadius: percentRadius.float)
	}
}
