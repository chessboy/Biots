//
//  GlobalDataComponent.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/07/27.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit
import OctopusKit

/// A custom component for the QuickStart project that holds some simple data to be shared across multiple game states and scenes.
final class GlobalDataComponent: OKComponent, OKUpdatableComponent, ObservableObject {
	    	
	@OKUserDefault(key: "showTracer", defaultValue: false) public var showTracer: Bool
	@OKUserDefault(key: "showPhysics", defaultValue: false) public var showPhysics: Bool
	@OKUserDefault(key: "showCellStats", defaultValue: false) public var showCellStats: Bool
	@OKUserDefault(key: "showCellSimpleStats", defaultValue: false) public var showCellSimpleStats: Bool
	@OKUserDefault(key: "showCellEyeSpots", defaultValue: false) public var showCellEyeSpots: Bool
	@OKUserDefault(key: "cameraZoom", defaultValue: Double(Constants.Camera.initialScale)) public var cameraZoom: Double

	@OKUserDefault(key: "showAlgaeFountainInfluences", defaultValue: false) public var showAlgaeFountainInfluences: Bool
	@OKUserDefault(key: "algaeTarget", defaultValue: 10000) public var algaeTarget: Int
	@OKUserDefault(key: "hideAlgae", defaultValue: false) public var hideAlgae: Bool
	@OKUserDefault(key: "showCellHealth", defaultValue: false) public var showCellHealth: Bool
	@OKUserDefault(key: "showCellVision", defaultValue: false) public var showCellVision: Bool
	@OKUserDefault(key: "showCellThrust", defaultValue: false) public var showCellThrust: Bool
}

