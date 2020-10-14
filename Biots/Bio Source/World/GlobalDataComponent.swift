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

struct Defaults {
	static let showPhysics = false
	static let cameraZoom = Double(Constants.Camera.initialScale)
	static let cameraX: Double = 0
	static let cameraY: Double = 0
	static let hideSpriteNodes = false
	
	static let showCellStats = false
	static let showCellVisionTracer = false
	static let showCellEyeSpots = false
	static let showCellHealth = false
	static let showCellHealthDetails = false
	static let showCellVision = false
	static let showCellThrust = false
	
	static let algaeTarget = 12000
	static let showAlgaeFountainInfluences = false
}

/// A custom component for the QuickStart project that holds some simple data to be shared across multiple game states and scenes.
final class GlobalDataComponent: OKComponent, OKUpdatableComponent, ObservableObject {
	@OKUserDefault(key: "showPhysics", defaultValue: Defaults.showPhysics) public var showPhysics: Bool
	@OKUserDefault(key: "cameraZoom", defaultValue: Defaults.cameraZoom) public var cameraZoom: Double
	@OKUserDefault(key: "cameraX", defaultValue: Defaults.cameraX) public var cameraX: Double
	@OKUserDefault(key: "cameraY", defaultValue: Defaults.cameraY) public var cameraY: Double
	@OKUserDefault(key: "hideSpriteNodes", defaultValue: Defaults.hideSpriteNodes) public var hideSpriteNodes: Bool

	@OKUserDefault(key: "showCellStats", defaultValue: Defaults.showCellStats) public var showCellStats: Bool
	@OKUserDefault(key: "showCellVisionTracer", defaultValue: Defaults.showCellVisionTracer) public var showCellVisionTracer: Bool
	@OKUserDefault(key: "showCellEyeSpots", defaultValue: Defaults.showCellEyeSpots) public var showCellEyeSpots: Bool
	@OKUserDefault(key: "showCellHealth", defaultValue: Defaults.showCellHealth) public var showCellHealth: Bool
	@OKUserDefault(key: "showCellHealthDetails", defaultValue: Defaults.showCellHealthDetails) public var showCellHealthDetails: Bool
	@OKUserDefault(key: "showCellVision", defaultValue: Defaults.showCellVision) public var showCellVision: Bool
	@OKUserDefault(key: "showCellThrust", defaultValue: Defaults.showCellThrust) public var showCellThrust: Bool

	@OKUserDefault(key: "algaeTarget", defaultValue: Defaults.algaeTarget) public var algaeTarget: Int
	@OKUserDefault(key: "showAlgaeFountainInfluences", defaultValue: Defaults.showAlgaeFountainInfluences) public var showAlgaeFountainInfluences: Bool
	
	func reset() {
		showPhysics = Defaults.showPhysics
		cameraZoom = Defaults.cameraZoom
		cameraX = Defaults.cameraX
		cameraY = Defaults.cameraY
		hideSpriteNodes = Defaults.hideSpriteNodes
	
		showCellStats = Defaults.showCellStats
		showCellVisionTracer = Defaults.showCellVisionTracer
		showCellEyeSpots = Defaults.showCellEyeSpots
		showCellHealth = Defaults.showCellHealth
		showCellHealthDetails = Defaults.showCellHealthDetails
		showCellVision = Defaults.showCellVision
		showCellThrust = Defaults.showCellThrust
	
		algaeTarget = Defaults.algaeTarget
		showAlgaeFountainInfluences = Defaults.showAlgaeFountainInfluences
		
		OctopusKit.logForSim.add("GlobalDataComponent: all observables have been reset")
	}
}

