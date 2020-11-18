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
	static let hideSpriteNodes = false
	
	static let showBiotStats = false
	static let showBiotVisionTracer = false
	static let showBiotEyeSpots = false
	static let showBiotHealth = false
	static let showBiotHealthDetails = false
	static let showBiotVision = false
	static let showBiotThrust = false
	static let showBiotExtras = false
	
	static let algaeTarget = 12000
	static let showAlgaeFountainInfluences = false
	
	static let showHUD = false
}

/// A custom component for the QuickStart project that holds some simple data to be shared across multiple game states and scenes.
final class GlobalDataComponent: OKComponent, OKUpdatableComponent, ObservableObject {
	
	@OKUserDefault(key: "showPhysics", defaultValue: Defaults.showPhysics) public var showPhysics: Bool
	@OKUserDefault(key: "hideSpriteNodes", defaultValue: Defaults.hideSpriteNodes) public var hideSpriteNodes: Bool

	@OKUserDefault(key: "showBiotStats", defaultValue: Defaults.showBiotStats) public var showBiotStats: Bool
	@OKUserDefault(key: "showBiotVisionTracer", defaultValue: Defaults.showBiotVisionTracer) public var showBiotVisionTracer: Bool
	@OKUserDefault(key: "showBiotEyeSpots", defaultValue: Defaults.showBiotEyeSpots) public var showBiotEyeSpots: Bool
	@OKUserDefault(key: "showBiotHealth", defaultValue: Defaults.showBiotHealth) public var showBiotHealth: Bool
	@OKUserDefault(key: "showBiotHealthDetails", defaultValue: Defaults.showBiotHealthDetails) public var showBiotHealthDetails: Bool
	@OKUserDefault(key: "showBiotVision", defaultValue: Defaults.showBiotVision) public var showBiotVision: Bool
	@OKUserDefault(key: "showBiotThrust", defaultValue: Defaults.showBiotThrust) public var showBiotThrust: Bool

	@OKUserDefault(key: "algaeTarget", defaultValue: Defaults.algaeTarget) public var algaeTarget: Int
	@OKUserDefault(key: "showAlgaeFountainInfluences", defaultValue: Defaults.showAlgaeFountainInfluences) public var showAlgaeFountainInfluences: Bool
	
	@OKUserDefault(key: "showHUD", defaultValue: Defaults.showHUD) public var showHUD: Bool

	override func didAddToEntity() {
		hideSpriteNodes = false
		showAlgaeFountainInfluences = false
		showHUDPub = showHUD
		showBiotHealth = false
		showBiotVision = false
		showBiotThrust = false
	}
	
	@Published
	public var showHUDPub: Bool = false {
		didSet {
			showHUD = showHUDPub
		}
	}

	func reset() {
		showPhysics = Defaults.showPhysics
		hideSpriteNodes = Defaults.hideSpriteNodes
	
		showBiotStats = Defaults.showBiotStats
		showBiotVisionTracer = Defaults.showBiotVisionTracer
		showBiotEyeSpots = Defaults.showBiotEyeSpots
		showBiotHealth = Defaults.showBiotHealth
		showBiotHealthDetails = Defaults.showBiotHealthDetails
		showBiotVision = Defaults.showBiotVision
		showBiotThrust = Defaults.showBiotThrust

		algaeTarget = Defaults.algaeTarget
		showAlgaeFountainInfluences = Defaults.showAlgaeFountainInfluences
		
		showHUD = Defaults.showHUD

		OctopusKit.logForSimInfo.add("GlobalDataComponent: all observables have been reset")
	}
}

