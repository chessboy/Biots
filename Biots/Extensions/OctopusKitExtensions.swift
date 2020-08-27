//
//  OctopusKitExtensions.swift
//  Biots
//
//  Created by Robert Silverman on 8/26/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import OctopusKit
import SpriteKit

extension OctopusComponent {
	
	var skColor: SKColor {
		if let node = entityNode as? SKShapeNode {
			return node.fillColor
		}
		return .white
	}
}

